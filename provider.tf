terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = ">=3.3.0"
      configuration_aliases = [azurerm]
    }
  }
  #backend "azurerm" {
  #    resource_group_name  = "tfstate"
  #    storage_account_name = "<storage_account_name>"
  #    container_name       = "tfstate"
  #    key                  = "terraform.tfstate"
  #}
}

provider "azurerm" {
    features {}
}
