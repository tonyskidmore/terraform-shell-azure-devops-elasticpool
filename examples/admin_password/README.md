# Azure Virtual Machine Scale Set

Example of creating an Azure VMSS with instances configured with an
administrator password as opposed to an SSH key pair
(SSH key pair is recommended).

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| azurerm | >=3.1.0 |
## Providers

| Name | Version |
|------|---------|
| azurerm | 3.29.1 |
## Modules

| Name | Source | Version |
|------|--------|---------|
| vmss | tonyskidmore/vmss/azurerm | 0.1.0 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vmss\_admin\_password | Password to allocate to the admin user account | `string` | `"Sup3rS3cr3tP@55w0rd!"` | no |
| vmss\_name | Name of the Virtual Machine Scale Set to create | `string` | `"vmss-agent-pool-linux-001"` | no |
| vmss\_resource\_group\_name | Existing resource group name of where the VMSS will be created | `string` | `"rg-vmss-azdo-agents-01"` | no |
| vmss\_subnet\_name | Name of subnet where the vmss will be connected | `string` | `"snet-azdo-agents-01"` | no |
| vmss\_vnet\_name | Name of the Vnet that the target subnet is a member of | `string` | `"vnet-azdo-agents-01"` | no |
| vmss\_vnet\_resource\_group\_name | Existing resource group where the Vnet containing the subnet is located | `string` | `"rg-azdo-agents-networks-01"` | no |
## Outputs

| Name | Description |
|------|-------------|
| vmss\_id | Virtual Machine Scale Set ID |

Example

```hcl
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
```
<!-- END_TF_DOCS -->
