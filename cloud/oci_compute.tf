locals {
  # For us-chicago-1
  canonical_ubuntu_24_04_aarch64_2024_05_20_0_us_chicago_1 = "ocid1.image.oc1.us-chicago-1.aaaaaaaa5l3wwpxokcl4u4nw4rhjcnfck36pwismqpdmp5urj4xdr4ku4hma"
  # Oracle free tier shape
  vm_standard_a1_flex = "VM.Standard.A1.Flex"
}

resource "oci_core_instance" "overwatch-instance" {
  # Required
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = oci_identity_compartment.aws-infra-cloud.id
  shape               = local.vm_standard_a1_flex
  shape_config {
    ocpus         = "3"
    memory_in_gbs = "18"
  }
  source_details {
    source_id   = local.canonical_ubuntu_24_04_aarch64_2024_05_20_0_us_chicago_1
    source_type = "image"
  }

  # Optional
  display_name = "overwatch"
  create_vnic_details {
    assign_public_ip = true
    subnet_id        = oci_core_subnet.vcn-public-subnet.id
  }
  metadata = {
    ssh_authorized_keys = var.oci_ssh_authorized_keys
  }
  preserve_boot_volume = false
}

resource "oci_core_instance" "canary-instance" {
  # Required
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = oci_identity_compartment.aws-infra-cloud.id
  shape               = local.vm_standard_a1_flex
  shape_config {
    ocpus         = "1"
    memory_in_gbs = "6"
  }
  source_details {
    source_id   = local.canonical_ubuntu_24_04_aarch64_2024_05_20_0_us_chicago_1
    source_type = "image"
  }

  # Optional
  display_name = "canary"
  create_vnic_details {
    assign_public_ip = true
    subnet_id        = oci_core_subnet.vcn-public-subnet.id
  }
  metadata = {
    ssh_authorized_keys = var.oci_ssh_authorized_keys
  }
  preserve_boot_volume = false
}
