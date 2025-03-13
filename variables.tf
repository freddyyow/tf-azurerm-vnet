variable "security_domain" {
  type = string

  validation {
    condition     = contains(["busops", "netops", "external"], var.security_domain)
    error_message = "inputted value must be one of ['busops', 'netops' or 'external']"
  }
}

variable "security_domain_hub_ip" {
  #type = map(object({}))
  type = map(any)
  default = {
    busops   = {
      next_hop = "10.160.0.4/32"
      vnet_id = ""
    }
    netops   = {
      next_hop = "10.168.0.4/32"
      vnet_id = ""
    }
    external = {
      next_hop =  "10.150.0.4/32"
      vnet_id = ""
   }
 }
}

variable "address_space" {

}

variable "location-prefix" {
  description = "shortform for the Azure region used in naming conventions"
  type = string

  default = "cc"

  validation {
    condition = contains(["cc", "ce", "ue1", "ue2"], var.location-prefix)
    error_message = "must contain region code of 'cc', 'ce', 'ue1' or 'ue2'"
  }

}

variable "location" {
  type = map(string)

  default = {
    cc = "canada central"
    ce = "canada east"
    ue1 = "us-east-1"
    ue2 = "us-east-2"

  }
}

variable "resource_group_name" {

}

variable "create_resource_group" {
  description = "Create resource group or use an existing one?"
  type = bool

  default = true

}

variable "subnet_config" {
  description = "value"
  type = map(object({
    address_prefix = list(string)
  }))

  default = {}
}

variable "subnet_delegation_settings" {
  type = map(object({
    delegation_name = optional(string)
    service_name = optional(string)
    actions =  optional(list(string))
  }))
  default = {}
  
}

variable "route_table_entry" {
  type = map(object({
    name           = string
    address_prefix = optional(string, "0.0.0.0/0")
    next_hop_type  = optional(string, "VirtualAppliance")
  }))
  default = {}
}

variable "target_environment" {
  description = "The environment to deploy (e.g., dev, staging, prod)"
  type        = string

  default = "DEV"

  validation {
    condition     = contains(["DEV", "STG", "PROD"], var.target_environment)
    error_message = "Value must be set to DEV, STG or PROD"
  }
}

variable "environment_map" {
  description = "map the shortform name to longform"
  type        = map(string)

  default = {
    "DEV"     = "development"
    "STAGING" = "staging"
    "PROD"    = "production"
  }
}

variable "tags" {
  description = "needs CostCentre, ApplicationName"
  default = {

  }
  
}

variable "application_name" {
  description = "value"
  type = string

  default = "ccms"
}

