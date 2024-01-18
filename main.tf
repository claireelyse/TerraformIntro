locals {
resource_group_name = "${var.rg}-${var.id}"

tags = {
  environment = var.id
  costcenter  = "12345"
  owner       = "me"
  project     = "myproject"
  managedby   = "terraform"
  }

}

#Resource Group
resource "azurerm_resource_group" "resource_group" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.tags
}

