# Azure DevOps Self-Hosted Elasticpool Agent

This example demonstrates adding an Azure DevOps Scale Set agent pool for
an existing Linux Azure Virtual Machine Scale Set (VMSS), as per the values configured
in the `terraform.tfvars` file.

Requirements

* [Terraform authenticated to the Azure subscription][tf-auth-azure] where the VMSS is located
* A deployed VMSS (`vmss-agent-pool-linux-001` in this example)
* An Azure DevOps Personal Access Token (as described in this project's `README.md`)
* An Azure DevOps Organization, Project and AzureRM Service Connection matching the configuration in `terraform.tfvars`.


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
| azurerm | 3.31.0 |
## Modules

| Name | Source | Version |
|------|--------|---------|
| azure-devops-elasticpool | tonyskidmore/azure-devops-elasticpool/shell | 0.3.0 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ado\_ext\_pat | Azure DevOps Personal Access Token | `string` | n/a | yes |
| ado\_org | Azure DevOps organization | `string` | n/a | yes |
| ado\_pool\_desired\_idle | Desired idle instances | `number` | `0` | no |
| ado\_pool\_name | Name of the Vnet that the target subnet is a member of | `string` | n/a | yes |
| ado\_project | Azure DevOps organization | `string` | n/a | yes |
| ado\_service\_connection | Azure DevOps organiservice connection name | `string` | n/a | yes |
| vmss\_name | Azure Virtual Machine Scale Set name | `string` | n/a | yes |
| vmss\_resource\_group\_name | Azure VMSS resource group name | `string` | n/a | yes |
## Outputs

| Name | Description |
|------|-------------|
| ado\_vmss\_pool\_output | Azure DevOps Elasticpool output |

Example

```hcl
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
```
<!-- END_TF_DOCS -->

[tf-auth-azure]: https://learn.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure?tabs=bash#specify-service-principal-credentials-in-environment-variables
