# Outputs

# Oracle Cloud Infra
output "overwatch-public-ip" {
  value = oci_core_instance.overwatch-instance.public_ip
}
output "canary-public-ip" {
  value = oci_core_instance.canary-instance.public_ip
}
