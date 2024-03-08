
#===================================
#management resource group
#===================================

# Create a resource group for the subscription
data "azurerm_resource_group" "Mangement"{
  name     = ""
}

resource "random_id" "random" {
  byte_length = 3
}


resource "azurerm_key_vault" "example" {
  name                        = "examplekeyvault${random_id.random.id}"
  location                    = data.azurerm_resource_group.Mangement.location
  resource_group_name         = data.azurerm_resource_group.Mangement.name
  enabled_for_disk_encryption = true
  tenant_id                   = ""
  sku_name = "standard"
}
