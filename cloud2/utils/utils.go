package utils

import (
	"github.com/1Password/pulumi-onepassword/sdk/go/onepassword"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi/config"
)

func Get1PasswordItem(ctx *pulumi.Context, itemName string) *onepassword.LookupItemResult {
	rootConfig := config.New(ctx, "")
	cloudflare, err := onepassword.LookupItem(ctx, &onepassword.LookupItemArgs{
		Vault: rootConfig.Require("vaultUUID"),
		Title: pulumi.StringRef(rootConfig.Require(itemName)),
	}, nil)
	if err != nil {
		panic(err)
	}
	return cloudflare
}
