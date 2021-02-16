variable "location" {
  description = "Location of the network"
  #  default     = ""
}

variable "username" {
  description = "Username for jumphost Virtual Machines"
  default     = "testadmin"
}

variable "password" {
  description = "Password for Virtual Machines"
  default     = "Password1234!"
}

variable "vmsize" {
  description = "Size of the VMs"
  default     = "Standard_DS1_v2"
}


variable "HubVnetCidr" {
  description = "enter Cidr range for hub vnet"
  # default     = ""
}

variable "AppGatewaySubnetCidr" {
  description = "enter Cidr range for Appgateway subnet"
  # default     = ""
}

variable "FirewallSubnetCidr" {
  description = "enter Cidr range for Firewall subnet"
  # default     = ""
}


variable "GatewaySubnetCidr" {
  description = "enter Cidr range for Gateway subnet"
  # default     = ""
}

variable "ManagementSubnetCidr" {
  description = "enter Cidr range for management subnet"
  # default     = ""
}

variable "ADSubnetCidr" {
  description = "enter Cidr range for AD Subnet"
  # default     = ""
}

variable "vm" {
  description = "enter name of jumphost vm"
  # default     = ""
}
