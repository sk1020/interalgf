#Set Variables for hub Network in this file


# Hub Network Location
location = "West US"

# Hub Vnet 
HubVnetCidr = ["10.0.0.0/16"]

# Application Subnet Gateway Cidr
AppGatewaySubnetCidr = "10.0.0.192/26"

# Firewall Subnet Mask should be /26 only"
FirewallSubnetCidr = "10.0.0.128/26"

# Gateway subnet 
GatewaySubnetCidr = "10.0.0.0/26"

# Management subnet 
ManagementSubnetCidr = "10.0.2.0/24"

# AD Subnet
ADSubnetCidr = "10.0.1.0/26"

# Set name for jumphost Virtual Machine
vm = "jumpbox-vm"
