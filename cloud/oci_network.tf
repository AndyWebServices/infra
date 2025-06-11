# Source from https://registry.terraform.io/modules/oracle-terraform-modules/vcn/oci/
module "vcn" {
  source  = "oracle-terraform-modules/vcn/oci"
  version = "3.6.0"
  # insert the 1 required variable here

  # Required Inputs
  compartment_id = oci_identity_compartment.aws-infra-cloud.id

  # Optional Inputs
  region = var.oci_region

  # Changing the following default values
  vcn_name                = "vcn-aws-primary"
  create_internet_gateway = true
  create_nat_gateway      = true
  create_service_gateway  = true

  # Using the following default values
  # vcn_dns_label = "vcnmodule"
  # vcn_cidrs = ["10.0.0.0/16"]
}

# Source from https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_security_list
resource "oci_core_security_list" "public-security-list" {

  # Required
  compartment_id = oci_identity_compartment.aws-infra-cloud.id
  vcn_id = module.vcn.vcn_id

  # Optional
  display_name = "security-list-for-public-subnet"
  egress_security_rules {
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

  # SSH Rule
  ingress_security_rules {
    stateless = false
    source    = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol  = "6"
    tcp_options {
      min = 22
      max = 22
    }
  }

  # HTTP/HTTPS Rules
  ingress_security_rules {
    stateless = false
    source    = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol  = "6"
    tcp_options {
      min = 80
      max = 80
    }
  }
  ingress_security_rules {
    stateless = false
    source    = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol  = "6"
    tcp_options {
      min = 443
      max = 443
    }
  }

  # ICMP Rules
  ingress_security_rules {
    stateless = false
    source    = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml ICMP is 1
    protocol  = "1"

    # For ICMP type and code see: https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml
    icmp_options {
      type = 3
      code = 4
    }
  }
  ingress_security_rules {
    stateless = false
    source    = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml ICMP is 1
    protocol  = "1"

    # For ICMP type and code see: https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml
    icmp_options {
      type = 3
    }
  }
}

# Source from https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_subnet
resource "oci_core_subnet" "vcn-public-subnet" {
  # Required
  compartment_id = oci_identity_compartment.aws-infra-cloud.id
  vcn_id         = module.vcn.vcn_id
  cidr_block = "10.0.0.0/24"

  # Optional
  route_table_id = module.vcn.ig_route_id
  security_list_ids = [oci_core_security_list.public-security-list.id]
  display_name   = "public-subnet"
}
