module "vnet-peering" {
  source       = "claranet/vnet-peering/azurerm"
  version      = "2.0.0"
  vnet_dest_id = "${module.network.vnet_id}"
  vnet_src_id  = azurerm_virtual_network.hub-vnet.id
}
