provider "azurerm" {
  features {}
}

provider "shell" {
  sensitive_environment = {
    AZURE_DEVOPS_EXT_PAT = var.ado_ext_pat
  }
}

data "azurerm_virtual_machine_scale_set" "ado_pool" {
  name                = var.vmss_name
  resource_group_name = var.vmss_resource_group_name
}

module "azure-devops-elasticpool" {
  source                 = "tonyskidmore/azure-devops-elasticpool/shell"
  version                = "0.3.0"
  ado_org                = var.ado_org
  ado_project            = var.ado_project
  ado_service_connection = var.ado_service_connection
  ado_pool_name          = var.ado_pool_name
  ado_pool_desired_idle  = var.ado_pool_desired_idle
  ado_vmss_id            = data.azurerm_virtual_machine_scale_set.ado_pool.id
}
