import os

import pulumi
import pulumi_tailscale as tailscale
import tldextract

from nextdns_provider import NextDNSRewrite

host_overrides = {
    'unas': {
        'names': [],
        'addresses': ['192.168.0.110'],
        'use_ts_addresses': False,
    },
    'traefik-traefik-ts': {
        'names': ['longhorn'],
        'addresses': [],
        'use_ts_addresses': True,
    }
}

config = pulumi.Config('infra-tailscale-nextdns-rewrites')
nextdns_tag = config.require('tagName')
second_level_domain = config.require('domainName')
tailnet_suffix = os.environ.get('TAILSCALE_TAILNET')


def ts_nextdns_rewrites():
    if not tailnet_suffix:
        raise ValueError("TAILSCALE_TAILNET is required")

    # Create a tldextract extractor with a custom suffix list
    extractor = tldextract.TLDExtract(
        extra_suffixes=[tailnet_suffix],  # treat entire tailnet as a suffix
    )

    ts_devices = tailscale.get_devices()
    for ts_device in ts_devices.devices:
        if nextdns_tag in ts_device.tags:
            # nextdns tag was matched. Machine needs a machine_name.domain_name -> IP A/AAAA record
            # machine_name = {name}.tailnet.ts.net
            machine_name = extractor(ts_device.name).domain

            # Get override info
            host_override = host_overrides.get(machine_name, {})
            names = [machine_name] + host_override.get('names', [])
            addresses = host_overrides.get('addresses', []) + (
                ts_device.addresses if host_override.get('use_ts_addresses', True) else [])

            for name in names:
                for address in addresses:
                    NextDNSRewrite(
                        name=f"{name}.{second_level_domain}",
                        content=address,
                    )
