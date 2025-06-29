package main

import (
	"bytes"
	"cloud/container"
	"cloud/oci"
	"cloud/utils"
	"encoding/base64"
	"fmt"
	"github.com/pulumi/pulumi-cloudflare/sdk/v6/go/cloudflare"
	"github.com/pulumi/pulumi-command/sdk/go/command/remote"
	"github.com/pulumi/pulumi-docker/sdk/v4/go/docker"
	"github.com/pulumi/pulumi-oci/sdk/v3/go/oci/core"
	"github.com/pulumi/pulumi-oci/sdk/v3/go/oci/identity"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
	"html/template"
)

func setupARecord(ctx *pulumi.Context, name string, content pulumi.StringOutput) (*cloudflare.DnsRecord, error) {
	return cloudflare.NewDnsRecord(ctx, fmt.Sprintf("a-record-%s", name), &cloudflare.DnsRecordArgs{
		Name:    pulumi.String(name),
		Comment: pulumi.String("Manage by pulumi via aws/infra/cloud"),
		Type:    pulumi.String("A"),
		Content: content,
		ZoneId:  pulumi.String("6dfb9abb8a292cebb7a9be4944886e29"),
		Proxied: pulumi.Bool(true),
		Ttl:     pulumi.Float64(1.0),
	})
}

func fillTemplate(path string, values map[string]interface{}) []byte {
	cloudInitTmpl, err := template.ParseFiles(path)
	if err != nil {
		panic(err)
	}
	var output bytes.Buffer
	err = cloudInitTmpl.Execute(&output, values)
	if err != nil {
		panic(err)
	}
	return output.Bytes()
}

func getCanaryContainers(
	ctx *pulumi.Context,
	user string,
	hostname string,
	privateKey string,
	instance *core.Instance,
	waitForCloudInit *remote.Command,
) container.CustomContainerConfigs {
	cloudflareApi := utils.Get1PasswordItem(ctx, "cloudflareUUID")

	return container.CustomContainerConfigs{
		&container.CustomContainerConfig{
			Name:          "ntfy",
			Subdomain:     "ntfy",
			ImageName:     "binwiederhier/ntfy",
			TraefikEnable: true,
			ContainerArgs: &docker.ContainerArgs{
				Command: pulumi.StringArray{pulumi.String("serve")},
				Envs:    pulumi.StringArray{pulumi.String("TZ=America/Chicago")},
				User:    pulumi.String("1001:1001"),
				Healthcheck: &docker.ContainerHealthcheckArgs{
					Tests: pulumi.StringArray{
						pulumi.String("CMD-SHELL"),
						pulumi.String("wget -q --tries=1 http://localhost:80/v1/health -O - | grep -Eo '\"healthy\"\\s*:\\s*true' || exit 1"),
					},
					Interval:    pulumi.String("1m0s"),
					Retries:     pulumi.Int(3),
					StartPeriod: pulumi.String("40s"),
					Timeout:     pulumi.String("10s"),
				},
			},
		},
		&container.CustomContainerConfig{
			Name:          "gatus",
			Subdomain:     "gatus",
			ImageName:     "twinproduction/gatus:latest",
			TraefikEnable: true,
			ContainerArgs: &docker.ContainerArgs{
				Envs: pulumi.StringArray{
					pulumi.String("PUID=1001"),
					pulumi.String("PGID=1001"),
					pulumi.String("TZ=America/Chicago"),
				},
				Volumes: docker.ContainerVolumeArray{
					&docker.ContainerVolumeArgs{
						ContainerPath: pulumi.String("/data/"),
						HostPath:      pulumi.String("/home/ubuntu/docker/composes/gatus-docker/data/"),
					},
				},
				Uploads: docker.ContainerUploadArray{
					&docker.ContainerUploadArgs{
						File: pulumi.String("/config/config.yaml"),
						Content: pulumi.String(
							fillTemplate("./configs/canary.gatus.config.yaml", map[string]interface{}{})),
					},
				},
			},
		},
		&container.CustomContainerConfig{
			Name:          "traefik",
			ImageName:     "docker.io/library/traefik:latest",
			TraefikEnable: false,
			ContainerArgs: &docker.ContainerArgs{
				Envs: pulumi.StringArray{
					pulumi.String("CF_DNS_API_TOKEN=" + cloudflareApi.Credential),
				},
				Ports: docker.ContainerPortArray{
					&docker.ContainerPortArgs{
						Internal: pulumi.Int(80),
						External: pulumi.Int(80),
						Ip:       instance.PrivateIp,
					},
					&docker.ContainerPortArgs{
						Internal: pulumi.Int(443),
						External: pulumi.Int(443),
						Ip:       instance.PrivateIp,
					},
					&docker.ContainerPortArgs{
						Internal: pulumi.Int(8080),
						External: pulumi.Int(8080),
						Ip:       oci.GetTailscaleIpv4(ctx, user, hostname, privateKey, instance, waitForCloudInit),
					},
				},
				Uploads: docker.ContainerUploadArray{
					&docker.ContainerUploadArgs{
						File: pulumi.String("/etc/traefik/traefik.yaml"),
						Content: pulumi.String(
							fillTemplate("./configs/canary.traefik.yaml", map[string]interface{}{})),
					},
				},
				Volumes: docker.ContainerVolumeArray{
					&docker.ContainerVolumeArgs{
						ContainerPath: pulumi.String("/var/run/docker.sock"),
						HostPath:      pulumi.String("/var/run/docker.sock"),
						ReadOnly:      pulumi.Bool(true),
					},
					&docker.ContainerVolumeArgs{
						ContainerPath: pulumi.String("/var/traefik/certs/"),
						HostPath:      pulumi.String("/home/ubuntu/docker/composes/traefik-docker/certs/"),
					},
				},
			},
		},
	}
}

func setupCanaryInstance(ctx *pulumi.Context, compartment *identity.Compartment, subnet *core.Subnet) error {

	const displayName = "canary"
	const memoryInGb = 6
	const oCpus = 1
	const cloudInitFilePath = "configs/oci_cloud_init.yaml"
	const user = "ubuntu"

	// Calculate user_data
	tailscaleAuthKeyItem := utils.Get1PasswordItem(ctx, "tailscaleAuthKeyUUID")
	sshKeyItem := utils.Get1PasswordItem(ctx, "sshKeyUUID")
	cloudflareItem := utils.Get1PasswordItem(ctx, "cloudflareUUID")

	cloudInitContent := fillTemplate(cloudInitFilePath, map[string]interface{}{
		"tailscale_auth_key": tailscaleAuthKeyItem.Credential,
		"user":               user,
	})

	metadata := pulumi.StringMap{
		"ssh_authorized_keys": pulumi.String(sshKeyItem.PublicKey),
		"user_data":           pulumi.String(base64.StdEncoding.EncodeToString(cloudInitContent)),
	}
	canaryInstance, canaryWaitForCloudInit, err := oci.SetupUbuntuInstance(ctx, displayName, user, memoryInGb, oCpus, metadata, compartment, subnet)
	if err != nil {
		return err
	}
	ctx.Export("canary_public_ip", canaryInstance.PublicIp)

	domain := cloudflareItem.Hostname
	aRecord, err := setupARecord(ctx, fmt.Sprintf("%s.%s", displayName, domain), canaryInstance.PublicIp)

	dockerProvider, err := container.SetupDockerProvider(ctx, displayName, user, canaryInstance.PublicIp, canaryInstance, canaryWaitForCloudInit)
	if err != nil {
		return err
	}

	configs := getCanaryContainers(ctx, user, displayName, sshKeyItem.PrivateKey, canaryInstance, canaryWaitForCloudInit)
	_, err = container.RunContainers(ctx, "canary", "lsio", configs, dockerProvider, aRecord)
	if err != nil {
		return err
	}
	return nil
}
