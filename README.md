# terraform-shell-azure-devops-elasticpool

Archived shell-based workaround for Azure DevOps VM scale set agent pools.

This repository is superseded by
`terraform-azuredevops-azure-devops-elasticpool`, which uses the native
`microsoft/azuredevops` provider resource `azuredevops_elastic_pool`.

## Status

- Archived for new development
- No new features will be added
- Retained only for historical reference and migration support

## Replacement

Use the provider-native replacement module instead:

- local branch path: `../terraform-azuredevops-azure-devops-elasticpool`
- intended registry source: `tonyskidmore/azure-devops-elasticpool/azuredevops`

The replacement removes the shell provider dependency and exposes
provider-native inputs such as:

- `name`
- `azure_resource_id`
- `service_endpoint_id`
- `service_endpoint_scope`
- `project_id`
- `desired_idle`
- `max_capacity`

## Migration

Consumers should move to:

1. provider-level Azure DevOps authentication
2. AzureRM service connection IDs instead of service connection names
3. project IDs instead of shell-specific project-only flags

For end-to-end VMSS plus pool provisioning, use the updated
`terraform-azurerm-vmss-devops-agent` module.
