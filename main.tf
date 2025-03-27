resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}


resource "azurerm_virtual_network" "virtual_network" {
  name                = "example-network"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.address_space
  #dns_servers         = ["10.0.0.4", "10.0.0.5"] # add as a separate resource so it can be conditional

  tags = merge(var.tags, local.common_tags)
}


resource "azurerm_subnet" "subnet" {
  for_each = var.subnet_config

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = each.value.address_prefix


  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }
  }
}

resource "azurerm_route_table" "route_table" {
  for_each            = var.route_table
  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name

  route {
    name                   = each.value.route_name
    address_prefix         = each.value.address_prefix
    next_hop_type          = each.value.next_hop_type
    next_hop_in_ip_address = var.security_domain_hub_ip[var.security_domain]
  }
}

# resource "azurerm_route" "route" {
#   name                   = "test"
#   route_table_name       = azurerm_route_table.route_table.name
#   resource_group_name    = var.resource_group_name
#   next_hop_type          = var.next_hop_type
#   next_hop_in_ip_address = var.security_domain_hub_ip[var.security_domain]
#   address_prefix         = var.address_prefix
# }

resource "azurerm_subnet_route_table_association" "name" {
  for_each = azurerm_subnet.subnet.id

  route_table_id = azurerm_route_table.route_table.id
  subnet_id      = each.value

  depends_on = [azurerm_subnet.subnet]
}