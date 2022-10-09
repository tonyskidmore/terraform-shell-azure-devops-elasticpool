# Overview



<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_shell"></a> [shell](#requirement\_shell) | ~>1.7.10 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_shell"></a> [shell](#provider\_shell) | 1.7.10 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [shell_script.ado_vmss_pool](https://registry.terraform.io/providers/scottwinkler/shell/latest/docs/resources/script) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ado_ext_pat"></a> [ado\_ext\_pat](#input\_ado\_ext\_pat) | Azure DevOps personal access token | `string` | n/a | yes |
| <a name="input_ado_org"></a> [ado\_org](#input\_ado\_org) | Azure DevOps Organization name | `string` | n/a | yes |
| <a name="input_ado_pool_auth_all_pipelines"></a> [ado\_pool\_auth\_all\_pipelines](#input\_ado\_pool\_auth\_all\_pipelines) | Setting to determine if all pipelines are authorized to use this TaskAgentPool by default (at create only) | `string` | `"True"` | no |
| <a name="input_ado_pool_auto_provision_projects"></a> [ado\_pool\_auto\_provision\_projects](#input\_ado\_pool\_auto\_provision\_projects) | Setting to automatically provision TaskAgentQueues in every project for the new pool (at create only) | `string` | `"True"` | no |
| <a name="input_ado_pool_desired_idle"></a> [ado\_pool\_desired\_idle](#input\_ado\_pool\_desired\_idle) | Number of machines to have ready waiting for jobs | `number` | `0` | no |
| <a name="input_ado_pool_desired_size"></a> [ado\_pool\_desired\_size](#input\_ado\_pool\_desired\_size) | The desired size of the pool | `number` | `0` | no |
| <a name="input_ado_pool_max_capacity"></a> [ado\_pool\_max\_capacity](#input\_ado\_pool\_max\_capacity) | Maximum number of machines that will exist in the elastic pool | `number` | `2` | no |
| <a name="input_ado_pool_max_saved_node_count"></a> [ado\_pool\_max\_saved\_node\_count](#input\_ado\_pool\_max\_saved\_node\_count) | Keep machines in the pool on failure for investigation | `number` | `0` | no |
| <a name="input_ado_pool_name"></a> [ado\_pool\_name](#input\_ado\_pool\_name) | Azure DevOps agent pool name | `string` | `"azdo-vmss-pool-001"` | no |
| <a name="input_ado_pool_os_type"></a> [ado\_pool\_os\_type](#input\_ado\_pool\_os\_type) | Operating system type of the nodes in the pool | `string` | `"linux"` | no |
| <a name="input_ado_pool_recycle_after_use"></a> [ado\_pool\_recycle\_after\_use](#input\_ado\_pool\_recycle\_after\_use) | Discard machines after each job completes | `bool` | `false` | no |
| <a name="input_ado_pool_sizing_attempts"></a> [ado\_pool\_sizing\_attempts](#input\_ado\_pool\_sizing\_attempts) | The number of sizing attempts executed while trying to achieve a desired size | `number` | `0` | no |
| <a name="input_ado_pool_ttl_mins"></a> [ado\_pool\_ttl\_mins](#input\_ado\_pool\_ttl\_mins) | The minimum time in minutes to keep idle agents alive | `number` | `30` | no |
| <a name="input_ado_project"></a> [ado\_project](#input\_ado\_project) | Azure DevOps project name where service connection exists and optionally where pool will only be created | `string` | n/a | yes |
| <a name="input_ado_project_only"></a> [ado\_project\_only](#input\_ado\_project\_only) | Only create the agent pool in the Azure DevOps pool specified? (at create only) | `string` | `"False"` | no |
| <a name="input_ado_service_connection"></a> [ado\_service\_connection](#input\_ado\_service\_connection) | Azure DevOps azure service connection name | `string` | n/a | yes |
| <a name="input_ado_vmss_id"></a> [ado\_vmss\_id](#input\_ado\_vmss\_id) | Azure Virtual Machine Scale Set Resource ID if not created by the module | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ado_vmss_pool_output"></a> [ado\_vmss\_pool\_output](#output\_ado\_vmss\_pool\_output) | Azure DevOps VMSS Agent Pool output |
<!-- END_TF_DOCS -->

## Debuging

````bash

export TF_LOG=TRACE
export TF_LOG_PATH="./trace.log"

````

`[DEBUG] Starting execution...`

## Development

[Developing inside a Container](https://code.visualstudio.com/docs/remote/containers)

````bash

pre-commit install
pre-commit install-hooks

````
