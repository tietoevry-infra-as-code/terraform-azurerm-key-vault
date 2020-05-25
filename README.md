# Azure Key Vault Terraform Module

Terraform Module to create a Key Vault also adds required access policies for AD users and groups. This module also sends all logs to log analytic workspace, storage, or event hubs. 

## Module Usage

```
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

  # Access polices enable to other resources, AD users and AD groups.
  enabled_for_deployment          = "true"
  enabled_for_disk_encryption     = "true"
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
      # Access policies for AD Groups, you can provide list of Azure AD users and set permissions.
      # azure_ad_group_names = ["ADGroupName1", "ADGroupName2"]
      # secret_permissions   = ["get", "list", "set"]
    },
  ]

  secrets = {
    # Create a required Secrets as per your need.
    # use .tfvars file to manage the secret as variable to avoid security issues. 
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

```

## Configure Azure Key Vault firewalls and virtual networks

Azure Key Vault firewalls and virtual networks to restrict access to your key vault. The virtual network service endpoints for Key Vault) allow you to restrict access to a specified virtual network and set of IPv4 (internet protocol version 4) address ranges.

Default action is set to `Deny` when no network rules matched. A `virtual_network_subnet_ids` or `ip_rules` can be added to `network_acls` block to allow request that is not Azure Services.

``` 
module "key-vault" {
  source = "github.com/tietoevry-infra-as-code/terraform-azurerm-key-vault?ref=v1.0.0"

  # .... omitted

  network_acls {
    bypass                     = "AzureServices"
    default_action             = "Deny"
    ip_rules                   = [] # One or more IP Addresses, or CIDR Blocks to access this Key Vault.
    virtual_network_subnet_ids = [] # One or more Subnet ID's to access this Key Vault.
  }
  
# ....omitted

}
```

## Tagging

Use tags to organize your Azure resources and management hierarchy. You can apply tags to your Azure resources, resource groups, and subscriptions to logically organize them into a taxonomy. Each tag consists of a name and a value pair. For example, you can apply the name "Environment" and the value "Production" to all the resources in production. You can manage these values variables directly or mapping as a variable using `variables.tf`.

All Azure resources which support tagging can be tagged by specifying key-values in argument `tags`. Tag Name is added automatically on all resources. For example, you can specify `tags` like this:

```
module "key-vault" {
  source = "github.com/tietoevry-infra-as-code/terraform-azurerm-key-vault?ref=v1.0.0"
  create_resource_group   = false

  # ... omitted

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Owner       = "test-user"
  }
}  
```

## Inputs

Name | Description | Type | Default
---- | ----------- | ---- | -------
`key_vault_name` | The name of the Key Vault to be created |string| `""`
`resource_group_name` | The name of the resource group in which resources are created | string | `""`
`sku_pricing_tier`|The name of the SKU used for the Key Vault. The options are: `standard`, `premium`.|string|`"standard"`
`enabled_for_deployment`|Allow Virtual Machines to retrieve certificates stored as secrets from the Key Vault|string|`"false"`
`enabled_for_disk_encryption`|Allow Disk Encryption to retrieve secrets from the vault and unwrap keys|string|`"false"`
`enabled_for_template_deployment`|Allow Resource Manager to retrieve secrets from the Key Vault|string|`"false"`
`access_policies`|List of access policies for the Key Vault|list|`{}`
`azure_ad_user_principal_names`|List of user principal names of Azure AD users|list| `[]`
`azure_ad_group_names`|List of names of Azure AD groups|list|`[]`
`key_permissions`|List of key permissions, must be one or more from the following: `backup`, `create`, `decrypt`, `delete`, `encrypt`, `get`, `import`, `list`, `purge`, `recover`, `restore`, `sign`, `unwrapKey`, `update`, `verify` and `wrapKey`.|list|`[]`
`secret_permissions`|List of secret permissions, must be one or more from the following: `backup`, `delete`, `get`, `list`, `purge`, `recover`, `restore` and `set`. |list|`[]`
`certificate_permissions`|List of certificate permissions, must be one or more from the following: `backup`, `create`, `delete`, `deleteissuers`, `get`, `getissuers`, `import`, `list`, `listissuers`, `managecontacts`, `manageissuers`, `purge`, `recover`, `restore`, `setissuers` and `update`.|list|`[]`
`storage_permissions`|List of storage permissions, must be one or more from the following: `backup`, `delete`, `deletesas`, `get`, `getsas`, `list`, `listsas`, `purge`, `recover`, `regeneratekey`, `restore`, `set`, `setsas` and `update`. |list|`[]`
`network_acls`|Configure Azure Key Vault firewalls and virtual networks|list| `{}`
`secrets`|A map of secrets for the Key Vault|map| `{}`
`log_analytics_workspace_id`|The id of log analytic workspace to send logs and metrics. `null` value - not to create the monitoring diagnostic profile|string|`"null"`
`storage_account_id`|The id of storage account to send logs and metrics. `null` value - not to add storage account to monitoring diagnostic profile|string|`"null"`
`eventhub_name`| The name of eventhub name to send logs and metrics. `null` value - not to add eventhub to monitoring diagnostic profile|string| `"null"`
`logs_retention_in_days`|The workspace data retention in days. Possible values range between 30 and 730|number|`30`
`Tags`|A map of tags to add to all resources|map|`{}`

## Outputs

Name | Description
---- | -----------
`key_vault_id`|The ID of the Key Vault
`key_vault_name`|Name of key vault created
`key_vault_uri`|The URI of the Key Vault, used for performing operations on keys and secrets
`secrets`|A mapping of secret names and URIs
`Key_vault_references`|A mapping of Key Vault references for App Service and Azure Functions

## Resource Graph

![Resource Graph](graph.png)

## Authors

Module is maintained by [Kumaraswamy Vithanala](mailto:kumaraswamy.vithanala@tieto.com) with the help from other awesome contributors.

## Other resources

* [Azure Key Vault documentation (Azure Documentation)](https://docs.microsoft.com/en-us/azure/key-vault/)

* [Terraform AzureRM Provider Documentation](https://www.terraform.io/docs/providers/azurerm/index.html)