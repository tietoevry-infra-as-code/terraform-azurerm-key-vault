variable "resource_group_name" {
  description = "A container that holds related resources for an Azure solution"
  default     = ""
}

variable "key_vault_name" {
  description = "the name of the Key valut"
  default     = ""
}

variable "sku_pricing_tier" {
  description = "The name of the SKU used for the Key Vault. The options are: `standard`, `premium`."
  default     = "standard"
}

variable "enabled_for_deployment" {
  description = "Allow Virtual Machines to retrieve certificates stored as secrets from the key vault."
  default     = false
}

variable "enabled_for_disk_encryption" {
  description = "Allow Disk Encryption to retrieve secrets from the vault and unwrap keys."
  default     = false
}

variable "enabled_for_template_deployment" {
  description = "Allow Resource Manager to retrieve secrets from the key vault."
  default     = false
}

variable "access_policies" {
  description = "List of access policies for the Key Vault."
  default     = []
}

variable "network_acls" {
  description = "Network rules to apply to key vault."
  type        = object({ bypass = string, default_action = string, ip_rules = list(string), virtual_network_subnet_ids = list(string) })
  default     = null
}

variable "secrets" {
  type        = map(string)
  description = "A map of secrets for the Key Vault."
  default     = {}
}

variable "log_analytics_workspace_id" {
  description = "Specifies the ID of a Log Analytics Workspace where Diagnostics Data to be sent"
  default     = null
}

variable "logs_retention_in_days" {
  description = "The workspace data retention in days. Possible values range between 30 and 730."
  default     = "30"
}

variable "storage_account_id" {
  description = "The name of the storage account to store the all monitoring logs"
  default     = null
}

variable "eventhub_name" {
  description = "The name of eventhub"
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

