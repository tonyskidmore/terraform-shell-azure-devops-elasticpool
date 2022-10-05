# required variables
variable "ado_ext_pat" {
  type        = string
  description = "Azure DevOps personal access token"
}

variable "ado_org" {
  type        = string
  description = "Azure DevOps Organization name"
}


variable "ado_service_connection" {
  type        = string
  description = "Azure DevOps azure service connection name"
}

variable "ado_vmss_id" {
  type        = string
  description = "Azure Virtual Machine Scale Set Resource ID if not created by the module"
  default     = ""
}

variable "ado_project" {
  type        = string
  description = "Azure DevOps project name where service connection exists and optionally where pool will only be created"
}

# variables with predefined defaults


variable "ado_project_only" {
  type        = string
  description = "Only create the agent pool in the Azure DevOps pool specified?"
  default     = "False"

  validation {
    condition     = contains(["True", "False"], var.ado_project_only)
    error_message = "ado_project_only must be True or False."
  }
}

variable "ado_pool_desired_idle" {
  type        = number
  description = "Number of machines to have ready waiting for jobs"
  default     = 0
}

variable "ado_pool_desired_size" {
  type        = number
  description = "The desired size of the pool"
  default     = 0
}

variable "ado_pool_max_capacity" {
  type        = number
  description = "Maximum number of machines that will exist in the elastic pool"
  default     = 2
}

variable "ado_pool_max_saved_node_count" {
  type        = number
  description = "Keep machines in the pool on failure for investigation"
  default     = 0
}

variable "ado_pool_name" {
  type        = string
  description = "Azure DevOps agent pool name"
  default     = "azdo-vmss-pool-001"
}

variable "ado_pool_recycle_after_use" {
  type        = bool
  description = "Discard machines after each job completes"
  default     = false
}

variable "ado_pool_sizing_attempts" {
  type        = number
  description = "The number of sizing attempts executed while trying to achieve a desired size"
  default     = 0
}

variable "ado_pool_ttl_mins" {
  type        = number
  description = "The minimum time in minutes to keep idle agents alive"
  default     = 30
}

variable "ado_pool_auth_all_pipelines" {
  type        = string
  description = "Setting to determine if all pipelines are authorized to use this TaskAgentPool by default"
  default     = "True"

  validation {
    condition     = contains(["True", "False"], var.ado_pool_auth_all_pipelines)
    error_message = "ado_pool_auth_all_pipelines must be True or False."
  }
}

variable "ado_pool_auto_provision_projects" {
  type        = string
  description = "Setting to automatically provision TaskAgentQueues in every project for the new pool"
  default     = "False"

  validation {
    condition     = contains(["True", "False"], var.ado_pool_auto_provision_projects)
    error_message = "ado_pool_auto_provision_projects must be True or False."
  }
}
