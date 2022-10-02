output "ado_vmss_pool_output" {
  value       = shell_script.ado_vmss_pool.output
  description = "Azure DevOps VMSS Agent Pool output"
}
