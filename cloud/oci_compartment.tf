data "oci_identity_availability_domains" "ads" {
  compartment_id = var.oci_tenancy_ocid
}

resource "oci_identity_compartment" "aws-infra-cloud" {
  compartment_id = var.oci_tenancy_ocid
  description    = "Compartment for aws/infra/cloud resources."
  name           = "aws-infra-cloud"
}
