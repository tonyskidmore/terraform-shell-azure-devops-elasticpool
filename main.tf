resource "shell_script" "ado_vmss_pool" {
  # https://github.com/scottwinkler/terraform-provider-shell/issues/79
  dirty = false

  lifecycle_commands {
    create = file("${path.module}/scripts/create.sh")
    read   = file("${path.module}/scripts/read.sh")
    update = file("${path.module}/scripts/update.sh")
    delete = file("${path.module}/scripts/delete.sh")

  }

  environment = {
    AZ_VMSS_ID                    = var.ado_vmss_id
    ADO_ORG                       = var.ado_org
    ADO_PROJECT                   = var.ado_project
    ADO_PROJECT_ONLY              = var.ado_project_only
    ADO_SERVICE_CONNECTION        = var.ado_service_connection
    ADO_POOL_NAME                 = var.ado_pool_name
    ADO_POOL_DESIRED_IDLE         = var.ado_pool_desired_idle
    ADO_POOL_DESIRED_SIZE         = var.ado_pool_desired_size
    ADO_POOL_MAX_CAPACITY         = var.ado_pool_max_capacity
    ADO_POOL_MAX_SAVED_NODE_COUNT = var.ado_pool_max_saved_node_count
    ADO_POOL_RECYCLE_AFTER_USE    = var.ado_pool_recycle_after_use
    ADO_POOL_SIZING_ATTEMPTS      = var.ado_pool_sizing_attempts
    ADO_POOL_TTL_MINS             = var.ado_pool_ttl_mins
    ADO_POOL_AUTH_ALL_PIPELINES   = var.ado_pool_auth_all_pipelines
    ADO_POOL_AUTO_PROVISION       = var.ado_pool_auto_provision_projects
  }
}
