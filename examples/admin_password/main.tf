
data "azurerm_virtual_machine_scale_set" "ado_pool" {
  name                = var.vmss_name
  resource_group_name = var.vmss_resource_group_name
}

module "terraform-azurerm-vmss-devops-agent" {
  source = "../../"
  # this will be supplied by exporting TF_VAR_ado_ext_pat before running terraform
  # this an Azure DevOps Personal Access Token to create and manage the agent pool
  ado_ext_pat            = var.ado_ext_pat
  ado_org                = var.ado_org
  ado_project            = var.ado_project
  ado_service_connection = var.ado_service_connection
  ado_pool_name          = var.ado_pool_name
  ado_pool_desired_idle  = 0
  ado_vmss_id            = data.azurerm_virtual_machine_scale_set.ado_pool.id
}
