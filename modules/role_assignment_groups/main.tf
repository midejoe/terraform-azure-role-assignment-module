module "role_assignments" {
  source = "../../role-assignment"

  role_assignments = [
    {
      scope       = azurerm_resource_group.this.id
      group_names = ["group1", "group2", "group3"]
      role_names  = ["Reader", "Web Plan Contributor"]
    }
  ]
}