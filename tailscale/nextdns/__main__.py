import pulumi
import pulumi_tailscale as tailscale

from nextdns_provider import NextDNSRewrite

config = pulumi.Config(pulumi.get_project())
nextdns_tag = config.require('tagName')
nextdns_profile_id = config.require('nextdnsProfileId')
second_level_domain = config.require('secondLevelDomain')
additionalHostnames = config.require_object('additionalHostnames')

ts_devices = tailscale.get_devices()
for ts_device in ts_devices.devices:
    if nextdns_tag in ts_device.tags:
        for src_hostname in [ts_device.hostname] + additionalHostnames.get(ts_device.hostname, []):
            NextDNSRewrite(
                src=f"{src_hostname}.{second_level_domain}",
                content=ts_device.name,
                profile_id=nextdns_profile_id,
            )
