package oci

import (
	"github.com/pulumi/pulumi-command/sdk/go/command/remote"
	"github.com/pulumi/pulumi-oci/sdk/v3/go/oci/core"
	"github.com/pulumi/pulumi-oci/sdk/v3/go/oci/identity"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

func Setup(ctx *pulumi.Context) (*identity.Compartment, *core.Subnet, error) {
	// Setup common components
	compartment, err := setupCompartment(ctx)
	if err != nil {
		return nil, nil, err
	}
	vcnPublicSubnet, err := SetupSubnet(ctx, compartment)
	if err != nil {
		return nil, nil, err
	}

	return compartment, vcnPublicSubnet, nil
}

// The following values must be changed vary carefully
const sourceId = "ocid1.image.oc1.us-chicago-1.aaaaaaaa5l3wwpxokcl4u4nw4rhjcnfck36pwismqpdmp5urj4xdr4ku4hma" // Ubuntu 24.04 ARM image
const shape = "VM.Standard.A1.Flex"                                                                          // Free tier shape
func SetupUbuntuInstance(
	ctx *pulumi.Context,
	displayName string,
	user string,
	memoryInGb int,
	oCpus int,
	metadata pulumi.StringMap,
	compartment *identity.Compartment,
	subnet *core.Subnet,
) (*core.Instance, *remote.Command, error) {
	canaryInstance, waitForCloudInit, err := setupOciInstance(
		ctx,
		displayName,
		user,
		metadata,
		shape,
		core.InstanceShapeConfigArgs{
			MemoryInGbs: pulumi.Float64(memoryInGb),
			Ocpus:       pulumi.Float64(oCpus),
		},
		core.InstanceSourceDetailsArgs{
			SourceId:   pulumi.String(sourceId),
			SourceType: pulumi.String("image"),
		},
		compartment,
		subnet,
	)
	if err != nil {
		return nil, nil, err
	}
	return canaryInstance, waitForCloudInit, err
}
