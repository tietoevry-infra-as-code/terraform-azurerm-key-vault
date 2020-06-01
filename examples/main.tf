module "key-vault" {
  source = "github.com/tietoevry-infra-as-code/terraform-azurerm-key-vault?ref=v1.1.0"

  # Resource Group and Key Vault pricing tier details
  resource_group_name        = "rg-tieto-internal-shared-westeurope-002"
  key_vault_sku_pricing_tier = "premium"

  # (Required) Project_Name, Subscription_type and environment are must to create resource names.
  # Project name length should be `15` and contian Alphanumerics and hyphens only. 
  project_name      = "tieto-internal"
  subscription_type = "shared"
  environment       = "dev"

  # Adding Key valut logs to Azure monitoring and Log Analytics space
  log_analytics_workspace_id           = module.hub-spoke-network.log_analytics_workspace_id
  azure_monitor_logs_retention_in_days = 30
  storage_account_id                   = module.hub-spoke-network.storage_account_id

  #specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault
  enabled_for_deployment = "true"

  #specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys
  enabled_for_disk_encryption = "true"

  #specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault
  enabled_for_template_deployment = "true"

  # Once `Purge Protection` has been Enabled it's not possible to Disable it
  # Deleting the Key Vault with `Purge Protection` enabled will schedule the Key Vault to be deleted (currently 90 days)
  # Once `Soft Delete` has been Enabled it's not possible to Disable it.
  enable_purge_protection = false
  enable_soft_delete      = false

  # Access policies for users, you can provide list of Azure AD users and set permissions.
  # Make sure to use list of user principal names of Azure AD users.
  access_policies = [
    {
      azure_ad_user_principal_names = ["user1@example.com", "user2@example.com"]
      key_permissions               = ["get", "list"]
      secret_permissions            = ["get", "list"]
      certificate_permissions       = ["get", "import", "list"]
      storage_permissions           = ["backup", "get", "list", "recover"]
    },

    # Access policies for AD Groups, enable this feature to provide list of Azure AD groups and set permissions.
    {
      # azure_ad_group_names = ["ADGroupName1", "ADGroupName2"]
      # secret_permissions   = ["get", "list", "set"]
    },
  ]

  # Create a required Secrets as per your need.
  # When you Add `usernames` with empty password this module creates a strong random password 
  # use .tfvars file to manage the secrets as variables to avoid security issues. 
  secrets = {
    "message" = "Hello, world!"
    "vmpass"  = ""
  }

  # Adding TAG's to your Azure resources (Required)
  # ProjectName and Env are already declared above, to use them here or create a varible. 
  tags = {
    ProjectName  = "tieto-internal"
    Env          = "dev"
    Owner        = "user@example.com"
    BusinessUnit = "CORP"
    ServiceClass = "Gold"
  }
}
