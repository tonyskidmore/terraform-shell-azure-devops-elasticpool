variable "vmss_name" {
  type        = string
  description = "Name of the Virtual Machine Scale Set to create"
  default     = "vmss-agent-pool-linux-001"
}

variable "vmss_resource_group_name" {
  type        = string
  description = "Existing resource group name of where the VMSS will be created"
  default     = "rg-vmss-azdo-agents-01"
}

variable "vmss_vnet_resource_group_name" {
  type        = string
  description = "Existing resource group where the Vnet containing the subnet is located"
  default     = "rg-azdo-agents-networks-01"
}

variable "vmss_subnet_name" {
  type        = string
  description = "Name of subnet where the vmss will be connected"
  default     = "snet-azdo-agents-01"
}

variable "vmss_vnet_name" {
  type        = string
  description = "Name of the Vnet that the target subnet is a member of"
  default     = "vnet-azdo-agents-01"
}

variable "vmss_admin_password" {
  type        = string
  description = "Password to allocate to the admin user account"
  default     = "Sup3rS3cr3tP@55w0rd!"
}
