#terraform {
#  required_providers {
#    azurerm = {
#      source  = "hashicorp/azurerm"
#      version = ">=3.0.0"
#    }
#  }
#  backend "azurerm" {}
#}
#
#provider "azurerm" {
#  features {}
#}
terraform {
  required_version = ">=0.14"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
  backend "azurerm" {
    subscription_id      = ""
    resource_group_name  = ""
    storage_account_name = ""
    container_name       = ""
    key                  = "state.tfstate"
  }               
}
provider "azurerm" {
    features {}
}