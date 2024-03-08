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

data "azurerm_resource_group" "datarg" {
  name = local.resource_group_name
}

#Resource Group
resource "azurerm_resource_group" "resource_group" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.tags
}

resource "azurerm_storage_account" "storage_account" {
  name                     = "${local.resource_group_name}sa"
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = azurerm_resource_group.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.tags
}