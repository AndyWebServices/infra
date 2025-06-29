package oci

import (
	"github.com/pulumi/pulumi-oci/sdk/v3/go/oci/core"
	"github.com/pulumi/pulumi-oci/sdk/v3/go/oci/identity"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

func getSecurityListIngress() *core.SecurityListIngressSecurityRuleArray {
	return &core.SecurityListIngressSecurityRuleArray{
		&core.SecurityListIngressSecurityRuleArgs{
			IcmpOptions: &core.SecurityListIngressSecurityRuleIcmpOptionsArgs{
				Type: pulumi.Int(3),
			},
			Protocol:   pulumi.String("1"),
			Source:     pulumi.String("10.0.0.0/16"),
			SourceType: pulumi.String("CIDR_BLOCK"),
		},
		&core.SecurityListIngressSecurityRuleArgs{
			IcmpOptions: &core.SecurityListIngressSecurityRuleIcmpOptionsArgs{
				Code: pulumi.Int(4),
				Type: pulumi.Int(3),
			},
			Protocol:   pulumi.String("1"),
			Source:     pulumi.String("0.0.0.0/0"),
			SourceType: pulumi.String("CIDR_BLOCK"),
		},
		// Allow SSH
		&core.SecurityListIngressSecurityRuleArgs{
			Protocol:   pulumi.String("6"),
			Source:     pulumi.String("0.0.0.0/0"),
			SourceType: pulumi.String("CIDR_BLOCK"),
			TcpOptions: &core.SecurityListIngressSecurityRuleTcpOptionsArgs{
				Max: pulumi.Int(22),
				Min: pulumi.Int(22),
			},
		},
		// Allow HTTP/HTTPS
		&core.SecurityListIngressSecurityRuleArgs{
			Protocol:   pulumi.String("6"),
			Source:     pulumi.String("0.0.0.0/0"),
			SourceType: pulumi.String("CIDR_BLOCK"),
			TcpOptions: &core.SecurityListIngressSecurityRuleTcpOptionsArgs{
				Max: pulumi.Int(80),
				Min: pulumi.Int(80),
			},
		},
		&core.SecurityListIngressSecurityRuleArgs{
			Protocol:   pulumi.String("6"),
			Source:     pulumi.String("0.0.0.0/0"),
			SourceType: pulumi.String("CIDR_BLOCK"),
			TcpOptions: &core.SecurityListIngressSecurityRuleTcpOptionsArgs{
				Max: pulumi.Int(443),
				Min: pulumi.Int(443),
			},
		},
	}
}

func ociSetupVcn(ctx *pulumi.Context, compartment *identity.Compartment) (*core.Vcn, error) {
	// Create a new compartment
	vcn, err := core.NewVcn(ctx, "vcn", &core.VcnArgs{
		CidrBlock:     pulumi.String("10.0.0.0/16"),
		CompartmentId: compartment.ID(),
		DisplayName:   pulumi.String("aws-primary-vcn"),
	})
	if err != nil {
		return nil, err
	}
	return vcn, nil
}

func ociSetupVcnPublicSubnet(ctx *pulumi.Context, compartment *identity.Compartment, vcn *core.Vcn, internetGatewayRoute *core.RouteTable, publicSecurityList *core.SecurityList) (*core.Subnet, error) {
	vcnPublicSubnet, err := core.NewSubnet(ctx, "public-subnet", &core.SubnetArgs{
		CidrBlock:       pulumi.String("10.0.0.0/24"),
		CompartmentId:   compartment.ID(),
		DisplayName:     pulumi.String("public-subnet"),
		RouteTableId:    internetGatewayRoute.ID(),
		SecurityListIds: pulumi.StringArray{publicSecurityList.ID()},
		VcnId:           vcn.ID(),
	})
	if err != nil {
		return nil, err
	}
	return vcnPublicSubnet, nil
}

func ociSetupServiceGateway(ctx *pulumi.Context, compartment *identity.Compartment, vcn *core.Vcn) (*core.ServiceGateway, error) {
	// Create Service Gateway
	allOrdId := "ocid1.service.oc1.us-chicago-1.aaaaaaaakalxenk3rcszv74eamyc6dkjq6ngikfsdpctsll4nxw2lnfqbpbq"
	serviceGateway, err := core.NewServiceGateway(ctx, "service-gateway", &core.ServiceGatewayArgs{
		CompartmentId: compartment.ID(),
		DisplayName:   pulumi.String("service-gateway"),
		Services: core.ServiceGatewayServiceArray{
			&core.ServiceGatewayServiceArgs{
				ServiceId: pulumi.String(allOrdId),
			},
		},
		VcnId: vcn.ID(),
	})
	if err != nil {
		return nil, err
	}
	return serviceGateway, nil
}

func setupNatGateway(ctx *pulumi.Context, compartment *identity.Compartment, vcn *core.Vcn) (*core.NatGateway, error) {
	// Create NAT Gateway
	natGateway, err := core.NewNatGateway(ctx, "nat-gateway", &core.NatGatewayArgs{
		CompartmentId: compartment.ID(),
		DisplayName:   pulumi.String("nat-gateway"),
		VcnId:         vcn.ID(),
	})
	if err != nil {
		return nil, err
	}
	return natGateway, nil
}

func ociSetupSecurityList(ctx *pulumi.Context, compartment *identity.Compartment, vcn *core.Vcn, securityListIngressSecurityRuleArray *core.SecurityListIngressSecurityRuleArray) (*core.SecurityList, error) {
	// security-list-actual
	publicSecurityList, err := core.NewSecurityList(ctx, "security-list-actual", &core.SecurityListArgs{
		CompartmentId: compartment.ID(),
		DisplayName:   pulumi.String("security-list-for-public-subnet"),
		EgressSecurityRules: core.SecurityListEgressSecurityRuleArray{
			&core.SecurityListEgressSecurityRuleArgs{
				Destination:     pulumi.String("0.0.0.0/0"),
				DestinationType: pulumi.String("CIDR_BLOCK"),
				Protocol:        pulumi.String("all"),
			},
		},
		IngressSecurityRules: *securityListIngressSecurityRuleArray,
		VcnId:                vcn.ID(),
	})
	if err != nil {
		return nil, err
	}
	return publicSecurityList, nil
}

func ociSetupServiceGatewayRoute(ctx *pulumi.Context, compartment *identity.Compartment, vcn *core.Vcn, serviceGateway *core.ServiceGateway) error {
	// sgw-route
	_, err := core.NewRouteTable(ctx, "sgw-route", &core.RouteTableArgs{
		CompartmentId: compartment.ID(),
		DisplayName:   pulumi.String("service-gw-route"),
		RouteRules: core.RouteTableRouteRuleArray{
			&core.RouteTableRouteRuleArgs{
				Destination:     pulumi.String("all-ord-services-in-oracle-services-network"),
				DestinationType: pulumi.String("SERVICE_CIDR_BLOCK"),
				NetworkEntityId: serviceGateway.ID(),
			},
		},
		VcnId: vcn.ID(),
	})
	return err
}

func ociSetupNatRouteTable(ctx *pulumi.Context, compartment *identity.Compartment, vcn *core.Vcn, natGateway *core.NatGateway, serviceGateway *core.ServiceGateway) error {
	// nat-route-id
	_, err := core.NewRouteTable(ctx, "nat-route", &core.RouteTableArgs{
		CompartmentId: compartment.ID(),
		DisplayName:   pulumi.String("nat-route"),
		RouteRules: core.RouteTableRouteRuleArray{
			&core.RouteTableRouteRuleArgs{
				Destination:     pulumi.String("0.0.0.0/0"),
				DestinationType: pulumi.String("CIDR_BLOCK"),
				NetworkEntityId: natGateway.ID(),
			},
			&core.RouteTableRouteRuleArgs{
				Destination:     pulumi.String("all-ord-services-in-oracle-services-network"),
				DestinationType: pulumi.String("SERVICE_CIDR_BLOCK"),
				NetworkEntityId: serviceGateway.ID(),
			},
		},
		VcnId: vcn.ID(),
	})
	return err
}

func ociSetupInternetGatewayRouteTable(ctx *pulumi.Context, compartment *identity.Compartment, vcn *core.Vcn, internetGateway *core.InternetGateway) (*core.RouteTable, error) {
	// ig-route-id
	internetGatewayRoute, err := core.NewRouteTable(ctx, "ig-route", &core.RouteTableArgs{
		CompartmentId: compartment.ID(),
		DisplayName:   pulumi.String("internet-route"),
		RouteRules: core.RouteTableRouteRuleArray{
			&core.RouteTableRouteRuleArgs{
				Destination:     pulumi.String("0.0.0.0/0"),
				DestinationType: pulumi.String("CIDR_BLOCK"),
				NetworkEntityId: internetGateway.ID(),
			},
		},
		VcnId: vcn.ID(),
	})
	if err != nil {
		return nil, err
	}
	return internetGatewayRoute, nil
}

func ociSetupInternetGateway(ctx *pulumi.Context, compartment *identity.Compartment, vcn *core.Vcn) (*core.InternetGateway, error) {
	// Create Internet Gateway
	internetGatway, err := core.NewInternetGateway(ctx, "aws-internet-gateway", &core.InternetGatewayArgs{
		CompartmentId: compartment.ID(),
		DefinedTags:   nil,
		DisplayName:   pulumi.String("internet-gateway"),
		Enabled:       pulumi.Bool(true),
		FreeformTags:  nil,
		RouteTableId:  nil,
		VcnId:         vcn.ID(),
	}, pulumi.Protect(false))
	if err != nil {
		return nil, err
	}
	return internetGatway, nil
}

func SetupSubnet(ctx *pulumi.Context, compartment *identity.Compartment) (*core.Subnet, error) {
	vcn, err := ociSetupVcn(ctx, compartment)
	if err != nil {
		return nil, err
	}

	internetGateway, err := ociSetupInternetGateway(ctx, compartment, vcn)
	if err != nil {
		return nil, err
	}

	natGateway, err := setupNatGateway(ctx, compartment, vcn)
	if err != nil {
		return nil, err
	}

	serviceGateway, err := ociSetupServiceGateway(ctx, compartment, vcn)
	if err != nil {
		return nil, err
	}

	internetGatewayRoute, err := ociSetupInternetGatewayRouteTable(ctx, compartment, vcn, internetGateway)
	if err != nil {
		return nil, err
	}

	err = ociSetupNatRouteTable(ctx, compartment, vcn, natGateway, serviceGateway)
	if err != nil {
		return nil, err
	}

	err = ociSetupServiceGatewayRoute(ctx, compartment, vcn, serviceGateway)
	if err != nil {
		return nil, err
	}

	publicSecurityList, err := ociSetupSecurityList(ctx, compartment, vcn, getSecurityListIngress())
	if err != nil {
		return nil, err
	}

	vcnPublicSubnet, err := ociSetupVcnPublicSubnet(ctx, compartment, vcn, internetGatewayRoute, publicSecurityList)
	if err != nil {
		return nil, err
	}
	return vcnPublicSubnet, nil
}
