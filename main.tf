terraform {
  required_version = ">= 1.3.1"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.33"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = ">=2.37"
    }
  }
}

resource "azurerm_resource_group" "this" {
  name     = "rg-test"
  location = "northeurope"
}

#########################################
##Role assignment for users#############
#########################################

module "role_assignments" {
  source = "./role-assignment"

  role_assignments = [
    {
      scope                = azurerm_resource_group.this.id
      user_principal_names = ["user1@contoso.com", "user2@contoso.com"]
      role_names           = ["Reader", "Web Plan Contributor"]
    }
  ]
}



#########################################
##Role assignment for service_principals#
#########################################
resource "azurerm_resource_group" "this" {
  name     = "rg-terraform-northeu-001"
  location = "northeurope"
}

module "role_assignments" {
  source = "./role-assignment"

  role_assignments = [
    {
      scope      = azurerm_resource_group.this.id
      sp_names   = ["spname1", "spname2", "spname3"]
      role_names = ["Reader", "Web Plan Contributor"]
    }
  ]
}

##############################################
##Role assignment for user managed identities#
##############################################

resource "azurerm_user_assigned_identity" "this" {
  name                = "terraform-identity-001"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
}

module "role_assignments" {
  source = "./role-assignment"

  role_assignments = [
    {
      scope         = azurerm_resource_group.this.id
      principal_ids = [azurerm_user_assigned_identity.this.principal_id]
      role_names    = ["Reader", "Web Plan Contributor"]
    }
  ]
}

##############################################
#########Role assignment for groups ##########
##############################################

module "role_assignments" {
  source = "./role-assignment"

  role_assignments = [
    {
      scope       = azurerm_resource_group.this.id
      group_names = ["group1", "group2", "group3"]
      role_names  = ["Reader", "Web Plan Contributor"]
    }
  ]
}

##############################################
#########Role assignment for any resource ####
##############################################

resource "azurerm_log_analytics_workspace" "this" {
  name                = "log-terraform-northeu-001"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


module "role_assignments" {
  source = "./role-assignment"

  role_assignments = [
    {
      scope       = azurerm_resource_group.this.id
      group_names = ["group1", "group2", "group3"]
      role_names  = ["Reader", "Web Plan Contributor"]
    },
    {
      scope      = azurerm_log_analytics_workspace.this.id
      sp_names   = ["spname1", "spname2", "spname3"]
      role_names = ["Reader", "Web Plan Contributor"]
    },
    {
      scope                = azurerm_resource_group.this.id
      user_principal_names = ["user1@contoso.com", "user2@contoso.com"]
      role_names           = ["Reader", "Web Plan Contributor"]
    },
    {
      scope         = azurerm_log_analytics_workspace.this.id
      principal_ids = ["xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"]
      role_names    = ["Reader"]
    }
  ]
}

