module "key-vault" {
  source = "github.com/tietoevry-infra-as-code/terraform-azurerm-key-vault?ref=v1.0.0"

  # Resource Group and Key Vault pricing tier details
  resource_group_name = "rg-demo-westeurope-01"
  key_vault_name      = "demokeyvault"
  sku_pricing_tier    = "premium"

  # Adding Key valut logs to Azure monitoring and Log Analytics space
  log_analytics_workspace_id = module.hub-spoke-network.log_analytics_workspace_id
  logs_retention_in_days     = 30
  storage_account_id         = module.hub-spoke-network.storage_account_id
  eventhub_name              = module.hub-spoke-network.eventhub_name

  #specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault
  enabled_for_deployment = "true"
  #specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys
  enabled_for_disk_encryption = "true"
  #specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault
  enabled_for_template_deployment = "true"

  access_policies = [
    {
      # Access policies for users, you can provide list of Azure AD users and set permissions.
      azure_ad_user_principal_names = ["user1@example.com", "user2@example.com"]
      key_permissions               = ["get", "list"]
      secret_permissions            = ["get", "list"]
      certificate_permissions       = ["get", "import", "list"]
      storage_permissions           = ["backup", "get", "list", "recover"]
    },
    {
      # Access policies for AD Groups, enable this feature to provide list of Azure AD groups and set permissions.
      # azure_ad_group_names = ["ADGroupName1", "ADGroupName2"]
      # secret_permissions   = ["get", "list", "set"]
    },
  ]

  # Network policies for key vault. 
  network_acls = {
    bypass                     = "AzureServices"
    default_action             = "Deny"
    ip_rules                   = [] # One or more IP Addresses, or CIDR Blocks to access this Key Vault.
    virtual_network_subnet_ids = [] # One or more Subnet ID's to access this Key Vault.
  }

  secrets = {
    # Create a required Secrets as per your need. 
    # use .tfvars file to manage the secrets as variables to avoid security issues. 
    "message" = "Hello, world!"
    "vmpass"  = "my bad password"
  }

  # Adding TAG's to your Azure resources (Required)
  tags = {
    Terraform   = "true"
    Environment = "dev"
    Owner       = "test-user"
  }
}
