# Azure DevOps Self-Hosted Elasticpool Agent


<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| azurerm | >=3.1.0 |
| shell | ~>1.7.10 |
## Providers

| Name | Version |
|------|---------|
| azurerm | 3.29.1 |
## Modules

| Name | Source | Version |
|------|--------|---------|
| azure-devops-elasticpool | tonyskidmore/azure-devops-elasticpool/shell | 0.1.0 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ado\_ext\_pat | Azure DevOps Personal Access Token | `string` | n/a | yes |
| ado\_org | Azure DevOps organization | `string` | `"https://dev.azure.com/tonyskidmore"` | no |
| ado\_pool\_desired\_idle | Desired idle instances | `number` | `0` | no |
| ado\_pool\_name | Name of the Vnet that the target subnet is a member of | `string` | `"vmss-agent-pool-linux-001"` | no |
| ado\_project | Azure DevOps organization | `string` | `"ve-vmss"` | no |
| ado\_service\_connection | Azure DevOps organiservice connection name | `string` | `"ve-vmss"` | no |
| vmss\_name | Azure Virtual Machine Scale Set name | `string` | `"vmss-agent-pool-linux-001"` | no |
| vmss\_resource\_group\_name | Azure VMSS resource group name | `string` | `"rg-vmss-azdo-agents-01"` | no |
## Outputs

| Name | Description |
|------|-------------|
| ado\_vmss\_pool\_output | Azure DevOps Elasticpool output |

Example

```hcl

data "azurerm_virtual_machine_scale_set" "ado_pool" {
  name                = var.vmss_name
  resource_group_name = var.vmss_resource_group_name
}

module "azure-devops-elasticpool" {
  source  = "tonyskidmore/azure-devops-elasticpool/shell"
  version = "0.1.0"
  # this will be supplied by exporting TF_VAR_ado_ext_pat before running terraform
  # this an Azure DevOps Personal Access Token to create and manage the agent pool
  ado_ext_pat            = var.ado_ext_pat
  ado_org                = var.ado_org
  ado_project            = var.ado_project
  ado_service_connection = var.ado_service_connection
  ado_pool_name          = var.ado_pool_name
  ado_pool_desired_idle  = var.ado_pool_desired_idle
  ado_vmss_id            = data.azurerm_virtual_machine_scale_set.ado_pool.id
}
```
<!-- END_TF_DOCS -->
