resource "shell_script" "ado_vmss_pool" {
  # https://github.com/scottwinkler/terraform-provider-shell/issues/79
  dirty = var.ado_dirty

  lifecycle_commands {
    create = "bash ${path.module}/scripts/ado_elastic_pool.sh create"
    read   = "bash ${path.module}/scripts/ado_elastic_pool.sh read"
    update = "bash ${path.module}/scripts/ado_elastic_pool.sh update"
    delete = "bash ${path.module}/scripts/ado_elastic_pool.sh delete"
  }

  environment = {
    ADO_ORG                       = var.ado_org
    ADO_POOL_AUTH_ALL_PIPELINES   = var.ado_pool_auth_all_pipelines
    ADO_POOL_AUTO_PROVISION       = var.ado_pool_auto_provision_projects
    ADO_POOL_DESIRED_IDLE         = var.ado_pool_desired_idle
    ADO_POOL_DESIRED_SIZE         = var.ado_pool_desired_size
    ADO_POOL_MAX_CAPACITY         = var.ado_pool_max_capacity
    ADO_POOL_MAX_SAVED_NODE_COUNT = var.ado_pool_max_saved_node_count
    ADO_POOL_NAME                 = var.ado_pool_name
    ADO_POOL_OS_TYPE              = var.ado_pool_os_type
    ADO_POOL_RECYCLE_AFTER_USE    = var.ado_pool_recycle_after_use
    ADO_POOL_SIZING_ATTEMPTS      = var.ado_pool_sizing_attempts
    ADO_POOL_TTL_MINS             = var.ado_pool_ttl_mins
    ADO_PROJECT                   = var.ado_project
    ADO_PROJECT_ONLY              = var.ado_project_only
    ADO_SERVICE_CONNECTION        = var.ado_service_connection
    AZ_VMSS_ID                    = var.ado_vmss_id
    HTTP_CONNECT_TIMEOUT          = var.http_connect_timeout
    HTTP_MAX_TIME                 = var.http_max_time
    HTTP_RETRIES                  = var.http_retries
    HTTP_RETRIES_MAX_TIME         = var.http_retries_max_time
    HTTP_RETRY_DELAY              = var.http_retry_delay
  }
}
