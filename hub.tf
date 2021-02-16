locals {
  prefix-hub = "hub"
  # hub-location       = "Central US"
  hub-resource-group = "hub-vnet-rg"
  shared-key         = "4-v3ry-53cr37-1p53c-5h4r3d-k3y"
}

resource "azurerm_resource_group" "hub-vnet-rg" {
  name     = local.hub-resource-group
  location = var.location
}

resource "azurerm_virtual_network" "hub-vnet" {
  name                = "${local.prefix-hub}-vnet"
  location            = azurerm_resource_group.hub-vnet-rg.location
  resource_group_name = azurerm_resource_group.hub-vnet-rg.name
  address_space       = var.HubVnetCidr
  #address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "hub-environment"
  }
}

resource "azurerm_subnet" "hub-gateway-subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.hub-vnet-rg.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefix       = var.GatewaySubnetCidr
  # address_prefix       = "10.0.0.0/26"
}

resource "azurerm_subnet" "hub-mgmt" {
  name                 = "ManagementSubnet"
  resource_group_name  = azurerm_resource_group.hub-vnet-rg.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  # address_prefix       = "10.0.2.0/24" 
  address_prefix = var.ManagementSubnetCidr
}

resource "azurerm_subnet" "hub-dmz" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.hub-vnet-rg.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  #address_prefix       = "10.0.0.128/26"
  address_prefix = var.FirewallSubnetCidr
}


resource "azurerm_subnet" "app-gateway" {
  name                 = "appgateway"
  resource_group_name  = azurerm_resource_group.hub-vnet-rg.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefix       = var.AppGatewaySubnetCidr
  #address_prefix       = "10.0.0.192/26"
}


resource "azurerm_subnet" "ad-subnet" {
  name                 = "ActiveDirectorySubnet"
  resource_group_name  = azurerm_resource_group.hub-vnet-rg.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefix       = var.ADSubnetCidr
  #address_prefix       = "10.0.1.0/26"
}

resource "azurerm_network_interface" "hub-nic" {
  name                 = "${local.prefix-hub}-nic"
  location             = azurerm_resource_group.hub-vnet-rg.location
  resource_group_name  = azurerm_resource_group.hub-vnet-rg.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = local.prefix-hub
    subnet_id                     = azurerm_subnet.hub-mgmt.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = local.prefix-hub
  }
}

#Virtual Machine
resource "azurerm_virtual_machine" "hub-vm" {
  name                  = var.vm
  location              = azurerm_resource_group.hub-vnet-rg.location
  resource_group_name   = azurerm_resource_group.hub-vnet-rg.name
  network_interface_ids = [azurerm_network_interface.hub-nic.id]
  vm_size               = var.vmsize

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${local.prefix-hub}-vm"
    admin_username = var.username
    admin_password = var.password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = local.prefix-hub
  }
}

# Virtual Network Gateway
resource "azurerm_public_ip" "hub-vpn-gateway1-pip" {
  name                = "hub-vpn-gateway1-pip"
  location            = azurerm_resource_group.hub-vnet-rg.location
  resource_group_name = azurerm_resource_group.hub-vnet-rg.name

  allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "hub-vnet-gateway" {
  name                = "hub-vpn-gateway1"
  location            = azurerm_resource_group.hub-vnet-rg.location
  resource_group_name = azurerm_resource_group.hub-vnet-rg.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.hub-vpn-gateway1-pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.hub-gateway-subnet.id
  }
  depends_on = [azurerm_public_ip.hub-vpn-gateway1-pip]
}

/*resource "azurerm_virtual_network_gateway_connection" "hub-onprem-conn" {
  name                = "hub-onprem-conn"
  location            = azurerm_resource_group.hub-vnet-rg.location
  resource_group_name = azurerm_resource_group.hub-vnet-rg.name

  type           = "Vnet2Vnet"
  routing_weight = 1

  virtual_network_gateway_id      = azurerm_virtual_network_gateway.hub-vnet-gateway.id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.onprem-vpn-gateway.id

  shared_key = local.shared-key
}

 resource "azurerm_virtual_network_gateway_connection" "onprem-hub-conn" {
  name                = "onprem-hub-conn"
  location            = azurerm_resource_group.onprem-vnet-rg.location
  resource_group_name = azurerm_resource_group.onprem-vnet-rg.name
  type                            = "Vnet2Vnet"
  routing_weight = 1
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.onprem-vpn-gateway.id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.hub-vnet-gateway.id

  shared_key = local.shared-key
}  */

#Application Gateway

resource "azurerm_subnet" "app-gateway-backend" {
  name                 = "apbackend"
  resource_group_name  = azurerm_resource_group.hub-vnet-rg.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefix       = "10.0.0.80/28"
}

resource "azurerm_public_ip" "app-gateway-pip" {
  name                = "app-gateway-pip"
  location            = azurerm_resource_group.hub-vnet-rg.location
  resource_group_name = azurerm_resource_group.hub-vnet-rg.name

  allocation_method = "Dynamic"
}

locals {
  backend_address_pool_name      = "${azurerm_virtual_network.hub-vnet.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.hub-vnet.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.hub-vnet.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.hub-vnet.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.hub-vnet.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.hub-vnet.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.hub-vnet.name}-rdrcfg"
}

resource "azurerm_application_gateway" "appgateway" {
  name                = "appgateway"
  resource_group_name = azurerm_resource_group.hub-vnet-rg.name
  location            = azurerm_resource_group.hub-vnet-rg.location

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.app-gateway.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.app-gateway-pip.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/path1/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}

# Firewall
resource "azurerm_public_ip" "firewall-pip" {
  name                = "firewallpip"
  location            = azurerm_resource_group.hub-vnet-rg.location
  resource_group_name = azurerm_resource_group.hub-vnet-rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "firewall" {
  name                = "azfirewall"
  location            = azurerm_resource_group.hub-vnet-rg.location
  resource_group_name = azurerm_resource_group.hub-vnet-rg.name



  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.hub-dmz.id
    public_ip_address_id = azurerm_public_ip.firewall-pip.id
  }
}

