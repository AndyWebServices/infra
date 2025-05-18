import pulumi
import pulumi_tailscale as tailscale
from nextdns_provider import NextDNSRewrite

config = pulumi.Config(pulumi.get_project())
nextdns_tag = config.require('tagName')
nextdns_profile_id = config.require('nextdnsProfileId')

ts_devices = tailscale.get_devices()
for ts_device in ts_devices.devices:
    if nextdns_tag in ts_device.tags:
        NextDNSRewrite(
            src=f"{ts_device.hostname}.{config.require('mainDomain')}",
            content=ts_device.name,
            profile_id=nextdns_profile_id,
        )
