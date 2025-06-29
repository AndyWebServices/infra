package oci

import (
	"github.com/pulumi/pulumi-oci/sdk/v3/go/oci/identity"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi/config"
)

func getTenancyOcid(ctx *pulumi.Context) string {
	ociConfig := config.New(ctx, "oci")
	return ociConfig.Get("tenancyOcid")
}

func ociGetAvailabilityDomains(ctx *pulumi.Context) (*identity.GetAvailabilityDomainsResult, error) {
	// Get availability domain
	availabilityDomains, err := identity.GetAvailabilityDomains(ctx, &identity.GetAvailabilityDomainsArgs{
		CompartmentId: getTenancyOcid(ctx),
	}, nil)
	if err != nil {
		return nil, err
	}
	return availabilityDomains, nil
}

func setupCompartment(ctx *pulumi.Context) (*identity.Compartment, error) {
	// Create a new compartment
	compartment, err := identity.NewCompartment(ctx, "aws-infra-cloud-pulumi", &identity.CompartmentArgs{
		CompartmentId: pulumi.String(getTenancyOcid(ctx)),
		Description:   pulumi.String("Compartment for aws/infra/cloud resources."),
		Name:          pulumi.String("aws-infra-cloud-pulumi"),
	})
	if err != nil {
		return nil, err
	}
	return compartment, nil
}
