variable "project_name" {
  description = "Short project name used in resource names"
  type        = string
  default     = "cqrs-pub-sub-demo"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus2"
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = "cqrs-pub-sub-demo"
}

variable "vm_name" {
  description = "VM name"
  type        = string
  default     = "vm-cqrs-pub-sub-demo"
}

variable "vm_size" {
  description = "VM size"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Admin username for VM"
  type        = string
  default     = "azureuser"
}

variable "admin_ssh_public_key" {
  description = "SSH public key content"
  type        = string
  # Default depends on public key of admin
}

variable "servicebus_sku" {
  description = "Service Bus SKU"
  type        = string
  default     = "Standard"
}

variable "teammate_principal_object_ids" {
  description = "Object IDs (users, groups or service principals) to grant Contributor on the resource group"
  type        = list(string)
  default     = []
}

variable "teammate_ssh_public_keys" {
  description = "Extra SSH public keys appended to admin user's authorized_keys in the VM"
  type        = list(string)
  default     = []
}
