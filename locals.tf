locals {
  common_tags = {
    DeployedWith = "Terraform"
    Owner = "PlatformEngineering"
    Environment = var.environment_map[upper(var.target_environment)]
  }
  prefix = "${var.location-prefix}${var.application_name}-${lower(var.target_environment)}"

  address_space = cidrsubnets(var.address_space, )
}

