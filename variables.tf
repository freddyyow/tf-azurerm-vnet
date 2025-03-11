variable "security_domain" {
  type = string

  validation {
    condition     = contains(["busops", "netops", "external"], var.security_domain)
    error_message = "inputted value must be one of ['busops', 'netops' or 'external']"
  }
}

variable "security_domain_hub_ip" {
  type = map(string)

  default = {
    "busops"   = "10.160.0.4/32"
    "netops"   = "10.168.0.4/32"
    "external" = "10.150.0.4/32"
  }

}

variable "address_space" {

}

variable "tags" {

}

variable "location" {

}

variable "resource_group_name" {

}

variable "create_resource_group" {

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
    name           = string
    address_prefix = optional(string, "0.0.0.0/0")
    next_hop_type  = optional(string, "VirtualAppliance")
  }))
  default = {}
}

