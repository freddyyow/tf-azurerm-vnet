resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location[var.location-prefix]
}

resource "azurerm_virtual_network" "vnet" {
  name                = "example-network"
  location            = var.location[var.location-prefix]
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.address_space
  #dns_servers         = ["10.0.0.4", "10.0.0.5"] # add as a separate resource so it can be conditional

  tags = merge(var.tags, local.common_tags)
}


resource "azurerm_subnet" "subnet" {
  for_each = var.subnet_config

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value.address_prefix


  dynamic "delegation" {
    for_each = var.subnet_delegation_settings

    content {
      name = delegation.value.delegation_name
      service_delegation {
        name = delegation.validation.service_name
        actions = delegation.value.actions
      }
    }
  }  
}

resource "azurerm_route_table" "rt" {
  name                = "use-preix-here"
  location            = var.location[var.location-prefix]
  resource_group_name = var.resource_group_name

  
  tags = merge(var.tags, local.common_tags)
}

resource "azurerm_route" "route" {
  for_each = var.route_table_entry

  name                   = each.value.name
  route_table_name       = azurerm_route_table.rt.name
  resource_group_name    = azurerm_resource_group.rg.name
  next_hop_type          = each.value.next_hop_type
  next_hop_in_ip_address = var.security_domain_hub_ip[var.security_domain]
  address_prefix         = each.value.address_prefix
}

resource "azurerm_subnet_route_table_association" "name" {
  for_each = azurerm_subnet.subnet[*].id

  route_table_id = azurerm_route_table.rt.id
  subnet_id      = each.value

  depends_on = [azurerm_subnet.subnet]
}

resource "azurerm_virtual_network_peering" "vnet_peering" {
  name                      = "use-preix-here"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.vnet.name
  remote_virtual_network_id = var.security_domain_hub_ip[var.security_domain].vnet_id
}