# Map of hostnames to tags
# Tofu will disable key expiry for tagged devices, then attach tags to device
locals {
  _device_tags = {
    "overwatch" = ["tag:nextdns", "tag:ssh", "tag:webhost", "tag:k1-access", "tag:beszel", "tag:promiscuous"],
    "baseplate" = ["tag:nextdns", "tag:ssh", "tag:webhost"],
    "pikvm"     = ["tag:ssh", "tag:nextdns", "tag:webhost", "tag:pikvm"],
    "unas"      = ["tag:ssh", "tag:nextdns", "tag:promiscuous"],
    "unifi"     = ["tag:nextdns", "tag:ssh", "tag:webhost"],
    "unifi-cal" = ["tag:nextdns", "tag:ssh", "tag:webhost"],
    "aws-mm1"   = ["tag:nextdns", "tag:ssh", "tag:webhost", "tag:promiscuous", "tag:beszel"],
    "ha"   = ["tag:ssh", "tag:webhost", "tag:promiscuous"],
  }

  # WARNING: Do not modify below this line!!!

  # Create a new map where the string ".time-corn.ts.net" is appended to every key in device_tags
  device_tags = {
    for key, value in local._device_tags : "${key}.${var.tailnet}" => value
  }
}

# Fetch all devices based on the list of hostnames
data "tailscale_device" "devices" {
  for_each = toset(keys(local.device_tags)) # Iterate over the hostnames in the map
  name     = each.key
}

# Disable key expiry
resource "tailscale_device_key" "tagged_devices" {
  for_each = data.tailscale_device.devices

  device_id           = each.value.id # Reference the node_id from the data source
  key_expiry_disabled = true
}

# Apply tags to each device
resource "tailscale_device_tags" "tagged_devices" {
  for_each = data.tailscale_device.devices

  device_id = each.value.id                      # Reference the node_id from the data source
  tags      = local.device_tags[each.value.name] # Apply the tags from the map using each.key (hostname)
  depends_on = [tailscale_acl.as_hujson]
}

resource "tailscale_acl" "as_hujson" {
  overwrite_existing_content = true
  acl = file("./ts_acls.json5")
}
