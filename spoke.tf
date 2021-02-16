module "network" {
  source  = "Azure/network/azurerm"
  version = "2.0.0"

  resource_group_name = "spoke-rg"
  vnet_name           = "spoke-vnet"
  address_space       = "192.168.0.0/16"
  location            = "West US"
  subnet_prefixes     = ["192.168.1.0/27", "192.168.2.0/27"]
  subnet_names        = ["subnet1", "subnet2"]
}

module "compute" {
  source           = "Azure/compute/azurerm"
  version          = "2.0.0"
  is_windows_image = "true"

  # description = "Specify UbuntuServer, WindowsServer, RHEL, openSUSE-Leap, CentOS, Debian, CoreOS and SLES to get the latest image version of the specified os. 
  vm_os_simple        = "WindowsServer"
  vm_size             = "Standard_DS1_V2"
  nb_instances        = "1"
  admin_username      = "azureuser"
  admin_password      = "Adminwin22@@"
  vm_hostname         = "myvm"
  location            = "${module.network.location}"
  vnet_subnet_id      = "${module.network.vnet_subnets[0]}"
  resource_group_name = "${module.network.resource_group_name}"

}

/*module "compute1" {
  source  = "Azure/compute/azurerm"
  version = "2.0.0"

  location 		= "West US"
  vnet_subnet_id 	= "${module.network.vnet_subnets[1]}"
}*/

