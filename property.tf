terraform {
  required_providers {
    akamai = {
      source  = "akamai/akamai"
      version = ">= 2.0.0"
    }
  }
  required_version = ">= 0.13"
}

provider "akamai" {
  edgerc         = var.edgerc_path
  config_section = var.config_section
}

data "akamai_group" "group" {
  group_name  = "acedergr"
  contract_id = "ctr_1-5C13O2"
}

data "akamai_contract" "contract" {
  group_name = data.akamai_group.group.name
}

data "akamai_property_rules_template" "rules" {
  template_file = abspath("${path.module}/property-snippets/main.json")
}
}

resource "akamai_property" "dsa-codekai-net" {
  name        = "dsa.codekai.net"
  contract_id = data.akamai_contract.contract.id
  group_id    = data.akamai_group.group.id
  product_id  = "prd_Site_Accel"
  rule_format = "latest"
  }
  hostnames {
    cname_from             = "dsa.codekai.net"
    cname_to               = akamai_edge_hostname.dsa-acedergr-akamaized-net.edge_hostname
    cert_provisioning_type = "DEFAULT"
  }
  rules = data.akamai_property_rules_template.rules.json
}

resource "akamai_property_activation" "dsa-codekai-net" {
  property_id = akamai_property.dsa-codekai-net.id
  contact     = ["acedergr@akamai.com"]
  version     = akamai_property.dsa-codekai-net.latest_version
  network     = upper(var.env)
}
