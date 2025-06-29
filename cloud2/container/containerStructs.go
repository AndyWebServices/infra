package container

import (
	"github.com/pulumi/pulumi-docker/sdk/v4/go/docker"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi/config"
)

type CustomContainerConfig struct {
	Name          string
	Subdomain     string
	ImageName     string
	ContainerArgs *docker.ContainerArgs
	TraefikEnable bool
}

func (c *CustomContainerConfig) getURL(ctx *pulumi.Context) string {
	domain := config.New(ctx, "").Require("cfDomain")
	if c.TraefikEnable {
		if c.Subdomain != "" {
			return c.Subdomain + "." + domain
		}
		return c.Name + "." + domain
	}
	panic("getURL is not supported when TraefikEnable is false")
}

type CustomContainerConfigs []*CustomContainerConfig
