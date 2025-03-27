resource "azurerm_resource_group" "rg" {
  name     = "${local.prefix}-rg"
  location = var.location
}


resource "azurerm_virtual_network" "virtual_network" {
  name                = "${local.prefix}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.address_space
  #dns_servers         = ["10.0.0.4", "10.0.0.5"] # add as a separate resource so it can be conditional

  tags = merge(var.tags, local.common_tags)
}


resource "azurerm_subnet" "subnet" {
  for_each = var.subnet_config

  name                 = each.key
  resource_group_name  = azurerm_resource_group.rg.name
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
  #for_each            = var.route_table
  name                = each.key
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg

  route {
    name                   = var.route_table.route_name
    address_prefix         = var.route_table.address_prefix
    next_hop_type          = var.route_table.next_hop_type
    next_hop_in_ip_address = var.security_domain_hub[var.security_domain].ip
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

resource "azurerm_virtual_network_peering" "peering" {
  for_each = var.vnet_peering

  name                      = "${local.prefix}-peering"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.virtual_network.name
  remote_virtual_network_id = var.security_domain_hub[var.security_domain].id
}