variable "environment" {
    type = string
    description = "environment to depploy to"

    default = "dev"

    validation {
      condition = contains(["dev", "uat", "stg", "prod"])
      error_message = "only allowed values are dev, stg, uat, prod"
    }
  
}

variable "application_name" {
  
}

variable "security_domain" {
  type = string

  validation {
    condition     = contains(["busops", "netops", "external"], var.security_domain)
    error_message = "inputted value must be one of ['busops', 'netops' or 'external']"
  }
}

variable "security_domain_hub" {
  type = map(string)

  default = {
    busops = {
        ip = "10.160.0.4/32"
        vnet_id = "somevalue"

    }
  }

#   default = {
#     "busops"   = "10.160.0.4/32"
#     "netops"   = "10.168.0.4/32"
#     "external" = "10.150.0.4/32"
#   }
}

variable "address_space" {
    type = list(string)
    description = "CIDR range provided by network team"
}

variable "tags" {

}

variable "location" {
    type = string
    description = "the Azure region to deploy to"

    default = "canadacentral"

}

variable "subnet_config" {

}

variable "next_hop_type" {

}

variable "next_hop_in_ip_address" {

}

variable "address_prefix" {

}

variable "route_table" {
  type = map(object({
    route_name           = string
    address_prefix = optional(string, "0.0.0.0/0")
    next_hop_type  = optional(string, "VirtualAppliance")
  }))
  #default = {}
}

variable "vnet_peering" {
  
}

