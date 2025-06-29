package oci

import (
	"fmt"
	"github.com/1Password/pulumi-onepassword/sdk/go/onepassword"
	"github.com/pulumi/pulumi-command/sdk/go/command/remote"
	"github.com/pulumi/pulumi-oci/sdk/v3/go/oci/core"
	"github.com/pulumi/pulumi-oci/sdk/v3/go/oci/identity"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi/config"
	"strings"
)

func setupOciInstance(
	ctx *pulumi.Context,
	displayName string,
	user string,
	metadata pulumi.StringMap,
	shape string,
	shapeConfig core.InstanceShapeConfigArgs,
	sourceDetails core.InstanceSourceDetailsArgs,
	compartment *identity.Compartment,
	vcnPublicSubnet *core.Subnet,
) (*core.Instance, *remote.Command, error) {

	availabilityDomains, err := ociGetAvailabilityDomains(ctx)
	if err != nil {
		return nil, nil, err
	}

	instance, err := core.NewInstance(ctx, fmt.Sprintf("%s-instance", displayName), &core.InstanceArgs{
		AvailabilityDomain: pulumi.String(availabilityDomains.AvailabilityDomains[0].Name),
		CompartmentId:      compartment.ID(),
		CreateVnicDetails: core.InstanceCreateVnicDetailsArgs{
			AssignPublicIp: pulumi.String("true"),
			SubnetId:       vcnPublicSubnet.ID(),
		},
		DisplayName:        pulumi.String(displayName),
		Metadata:           metadata,
		PreserveBootVolume: pulumi.Bool(false),
		Shape:              pulumi.String(shape),
		ShapeConfig:        shapeConfig,
		SourceDetails:      sourceDetails,
	}, pulumi.DeleteBeforeReplace(true))
	if err != nil {
		return nil, nil, err
	}

	rootConfig := config.New(ctx, "")
	// Calculate user_data
	sshKey, err := onepassword.LookupItem(ctx, &onepassword.LookupItemArgs{
		Vault: rootConfig.Require("vaultUUID"),
		Title: pulumi.StringRef(rootConfig.Require("sshKeyUUID")),
	}, nil)
	if err != nil {
		return nil, nil, err
	}

	// Wait for cloud init
	waitForCloudInitReady, err := remote.NewCommand(ctx, fmt.Sprintf("%s-wait-for-cloud-init-ready", displayName), &remote.CommandArgs{
		Create: pulumi.String("while [ ! -f /var/lib/cloud/instance/boot-finished ]; do sleep 5; done"),
		Connection: &remote.ConnectionArgs{
			PerDialTimeout: pulumi.Int(15),
			DialErrorLimit: pulumi.Int(20), // This should be enough for host to boot up
			Host:           instance.PublicIp,
			User:           pulumi.String(user),
			PrivateKey:     pulumi.String(sshKey.PrivateKey),
		},
	}, pulumi.ReplaceOnChanges([]string{"connection"}), pulumi.Parent(instance))
	if err != nil {
		return nil, nil, err
	}

	return instance, waitForCloudInitReady, nil
}

func GetTailscaleIpv4(
	ctx *pulumi.Context,
	user string,
	hostname string,
	privateKey string,
	instance *core.Instance,
	waitForCloudInit *remote.Command,
) pulumi.StringOutput {
	// Wait for cloud init, get tailscale ips
	tailscaleIpCmd, _ := remote.NewCommand(
		ctx,
		fmt.Sprintf("%s-get-tailscale-ip", hostname),
		&remote.CommandArgs{
			Create: pulumi.String("tailscale ip"),
			Connection: &remote.ConnectionArgs{
				PerDialTimeout: pulumi.Int(15),
				DialErrorLimit: pulumi.Int(20), // This should be enough for host to boot up
				Host:           instance.PublicIp,
				User:           pulumi.String(user),
				PrivateKey:     pulumi.String(privateKey),
			},
		},
		pulumi.ReplaceOnChanges([]string{"connection"}),
		pulumi.DependsOn([]pulumi.Resource{waitForCloudInit}),
		pulumi.Parent(waitForCloudInit),
	)
	// Parse the first IP address
	tailscaleIpv4 := tailscaleIpCmd.Stdout.ApplyT(func(s string) string {
		parts := strings.Split(strings.TrimSpace(s), "\n")
		return parts[0]
	}).(pulumi.StringOutput)

	ctx.Export(fmt.Sprintf("canary-ts-ipv4-%s", hostname), tailscaleIpv4)
	return tailscaleIpv4
}
