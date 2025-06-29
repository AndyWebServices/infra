package container

import (
	"fmt"
	"github.com/pulumi/pulumi-cloudflare/sdk/v6/go/cloudflare"
	"github.com/pulumi/pulumi-command/sdk/go/command/remote"
	"github.com/pulumi/pulumi-docker/sdk/v4/go/docker"
	"github.com/pulumi/pulumi-oci/sdk/v3/go/oci/core"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

func setupCnameRecord(ctx *pulumi.Context, name string, content pulumi.StringOutput) (*cloudflare.DnsRecord, error) {
	return cloudflare.NewDnsRecord(ctx, fmt.Sprintf("cname-record-%s", name), &cloudflare.DnsRecordArgs{
		Name:    pulumi.String(name),
		Comment: pulumi.String("Manage by pulumi via aws/infra/cloud"),
		Type:    pulumi.String("CNAME"),
		Content: content,
		ZoneId:  pulumi.String("6dfb9abb8a292cebb7a9be4944886e29"),
		Ttl:     pulumi.Float64(1.0),
	})
}

func SetupDockerProvider(
	ctx *pulumi.Context,
	instanceName string,
	user string,
	publicIp pulumi.StringOutput,
	instance *core.Instance,
	waitForCloudInit *remote.Command,
) (*docker.Provider, error) {
	// Attach a docker provider to host
	dockerProvider, err := docker.NewProvider(
		ctx,
		fmt.Sprintf("%s-docker-provider", instanceName),
		&docker.ProviderArgs{
			DisableDockerDaemonCheck: pulumi.Bool(false),
			Host:                     pulumi.Sprintf("ssh://%s@%s", user, publicIp),
			SshOpts: pulumi.StringArray{
				pulumi.String("-o"), pulumi.String("ConnectTimeout=120"),
				pulumi.String("-o"), pulumi.String("StrictHostKeyChecking=no"),
			},
		},
		pulumi.ReplaceOnChanges([]string{"host"}),
		pulumi.DependsOn([]pulumi.Resource{waitForCloudInit}),
		pulumi.DeletedWith(instance),
		pulumi.Parent(waitForCloudInit),
	)
	if err != nil {
		return nil, err
	}

	return dockerProvider, nil
}

func runContainer(
	ctx *pulumi.Context,
	hostname string,
	networkName string,
	containerConfig *CustomContainerConfig,
	dockerNetwork *docker.Network,
	dockerProvider *docker.Provider,
	aRecord *cloudflare.DnsRecord,
) (*docker.Container, error) {

	dockerImage, err := docker.NewRemoteImage(
		ctx,
		fmt.Sprintf("%s-%s-%s-image", hostname, networkName, containerConfig.Name),
		&docker.RemoteImageArgs{
			Name: pulumi.String(containerConfig.ImageName),
		},
		pulumi.Provider(dockerProvider),
		pulumi.DeletedWith(dockerProvider),
		pulumi.DependsOn([]pulumi.Resource{dockerProvider}),
		pulumi.Parent(dockerProvider),
	)
	if err != nil {
		return nil, err
	}

	// Start a container
	containerConfig.ContainerArgs.Name = pulumi.String(containerConfig.Name)
	containerConfig.ContainerArgs.Image = dockerImage.ImageId
	containerConfig.ContainerArgs.NetworksAdvanced = docker.ContainerNetworksAdvancedArray{
		&docker.ContainerNetworksAdvancedArgs{
			Name: dockerNetwork.ID(),
		},
	}
	if containerConfig.TraefikEnable {
		_, err = setupCnameRecord(ctx, containerConfig.getURL(ctx), aRecord.Name)
		if err != nil {
			return nil, err
		}

		containerConfig.ContainerArgs.Labels = docker.ContainerLabelArray{
			&docker.ContainerLabelArgs{
				Label: pulumi.String("traefik.enable"),
				Value: pulumi.String("true"),
			},
			&docker.ContainerLabelArgs{
				Label: pulumi.String(fmt.Sprintf("traefik.http.routers.%s.rule", containerConfig.Name)),
				Value: pulumi.String(fmt.Sprintf("Host(`%s`)", containerConfig.getURL(ctx))),
			},
			&docker.ContainerLabelArgs{
				Label: pulumi.String(fmt.Sprintf("traefik.http.routers.%s.entrypoints", containerConfig.Name)),
				Value: pulumi.String("websecure"),
			},
			&docker.ContainerLabelArgs{
				Label: pulumi.String(fmt.Sprintf("traefik.http.routers.%s.tls", containerConfig.Name)),
				Value: pulumi.String("true"),
			},
			&docker.ContainerLabelArgs{
				Label: pulumi.String(fmt.Sprintf("traefik.http.routers.%s.tls.certresolver", containerConfig.Name)),
				Value: pulumi.String("letsencrypt"),
			},
		}
	}

	container, err := docker.NewContainer(
		ctx,
		fmt.Sprintf("%s-%s-%s-container", hostname, networkName, containerConfig.Name),
		containerConfig.ContainerArgs,
		pulumi.DeletedWith(dockerProvider),
		pulumi.DependsOn([]pulumi.Resource{dockerProvider}),
		pulumi.Parent(dockerNetwork),
		pulumi.DeleteBeforeReplace(true),
	)
	if err != nil {
		return nil, err
	}

	return container, nil
}

func RunContainers(
	ctx *pulumi.Context,
	hostname string,
	networkName string,
	configs CustomContainerConfigs,
	dockerProvider *docker.Provider,
	aRecord *cloudflare.DnsRecord,
) ([]*docker.Container, error) {

	// setup docker network lsio
	dockerNetwork, err := docker.NewNetwork(
		ctx,
		fmt.Sprintf("%s-%s-network", hostname, networkName),
		&docker.NetworkArgs{Name: pulumi.String(networkName)},
		pulumi.Provider(dockerProvider),
		pulumi.DeletedWith(dockerProvider),
		pulumi.DependsOn([]pulumi.Resource{dockerProvider}),
		pulumi.Parent(dockerProvider),
		pulumi.DeleteBeforeReplace(true),
	)
	if err != nil {
		return nil, err
	}

	var containers []*docker.Container
	for _, customConfig := range configs {
		container, err := runContainer(ctx, hostname, networkName, customConfig, dockerNetwork, dockerProvider, aRecord)
		if err != nil {
			return nil, err
		}
		containers = append(containers, container)
	}
	return containers, nil
}
