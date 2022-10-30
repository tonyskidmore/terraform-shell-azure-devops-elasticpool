data "azurerm_subnet" "agents" {
  name                 = var.vmss_subnet_name
  virtual_network_name = var.vmss_vnet_name
  resource_group_name  = var.vmss_vnet_resource_group_name
}

module "vmss" {
  source                   = "tonyskidmore/vmss/azurerm"
  version                  = "0.1.0"
  vmss_name                = var.vmss_name
  vmss_resource_group_name = var.vmss_resource_group_name
  vmss_subnet_id           = data.azurerm_subnet.agents.id
  vmss_admin_password      = var.vmss_admin_password
}
