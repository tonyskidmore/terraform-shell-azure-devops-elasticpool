variable "vmss_name" {
  type        = string
  description = "Azure Virtual Machine Scale Set name"
}

variable "vmss_resource_group_name" {
  type        = string
  description = "Azure VMSS resource group name"
}

variable "ado_ext_pat" {
  type        = string
  description = "Azure DevOps Personal Access Token"
}

variable "ado_org" {
  type        = string
  description = "Azure DevOps organization"
}

variable "ado_project" {
  type        = string
  description = "Azure DevOps organization"
}

variable "ado_service_connection" {
  type        = string
  description = "Azure DevOps organiservice connection name"
}

variable "ado_pool_name" {
  type        = string
  description = "Name of the Vnet that the target subnet is a member of"
}

variable "ado_pool_desired_idle" {
  type        = number
  description = "Desired idle instances"
  default     = 0
}
