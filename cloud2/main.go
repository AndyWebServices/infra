package main

import (
	"cloud/oci"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

func main() {
	pulumi.Run(func(ctx *pulumi.Context) error {

		// Setup OCI-related stack
		compartment, subnet, err := oci.Setup(ctx)
		if err != nil {
			return err
		}
		err = setupCanaryInstance(ctx, compartment, subnet)
		if err != nil {
			return err
		}

		return nil
	})
}
