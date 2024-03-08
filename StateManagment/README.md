# Infrastructure As Code
This repository contains all code and pipelines required to deploy Infrastructure.

## State Management
If for some reason you need to manage state outside of the Pipelines created please follow the below steps. Examples are done in a Powershell 7 terminal (pwsh).

To complete this activity you need to have Terraform and Azure cli installed. The easies way to do this is to use an Azure cloud shell since it will have both tools installed and already inherit your user accesslog you in.

####  1) Log into azure from a terminal examples are done in a Powershell 7 terminal (pwsh) with an account that has access to both the key vault and the storage account that manage Terraform state. 
``` cli
$tenantid =  
$subscriptionid = 
az login --tenant $tenantid
az account set -s $subscriptionid 
```

#### 2) create a main.tf with the backend info set correctly for the state file you need to manage.
``` hcl
terraform {
  required_version = =0.14
  required_providers {
    azurerm = {
      source  = hashicorpazurerm
      version = = 3.0
    }
  }
  backend azurerm {
    subscription_id      = 
    resource_group_name  = 
    storage_account_name = 
    container_name       = 
    key                  = state.tfstate
  }               
}
provider azurerm {
    features {}
}
```

#### 3) find empty state files in the storage account container

change the key value until you find a state file that returns the below results
``` hcl
terraform state list
```
expected value nothing

``` hcl
terraform workspace list
```
expected value  default

if both of these values are empty then you can delete the blob that is named after your key. 

Another way to look at this is if your state file has this appended to the end envManagementGroup
like this
``` hcl
state.tfstateenvManagementGroup 
```
then you know that there is a workspace associated and you must clean up each associated workspace before deleting the original state file. 

#### 4) Clean up empty workspaces
When you find a state file with no resources in the default state file but does have a non default workspace then run the below command to list the resources inside that workspace

``` hcl
terraform workspace select workspacename
terraform state list
```

#### 5) Move managed resources to a diffrent state file
I like to use the rm and add as the ways to do this. The terraform mv command will only move a resource to a new resource name (most commonly used when moving resources into or out of a module)

You will need 2 pieces of information terraformID and AzureResourceId
for terraform id  run 
``` hcl
terraform state list
```
and each line will  be the terraform resource id with the naming standard
module.providerName.friendlyName
note objects that do not need to be imported data, subscriptions imported with an alias 

to get the Azure resource grab the ID field when you run 
```hcl
terraform state show terraformID
```
do this for every line item you want to move in the state file. 



I like to do all the collection of resources before I actually run any commands - especially before I remove anything from state. If you want a template my working files usually look something like this

``` hcl
## move ManagementGroup resources

key = ManagementGroupstate.tfstate
workspace = ManagementGroup

terraform state rm <terraform resource id>


key = state.tfstate
workspace = ManagementGroup

terraform import <terraform resource id> <azure resource id>
```


#### 6) Import resources to new state file.
I prefer to run the import into the new state file before I clean up the old state file.

change the init to point to the new state file and workspace using the backend key, make sure the resource blocks are created in your main file and run
``` hcl
terraform import terraformID AzureResourceId
```
Note this will not create the resource this will just tell terraform to start tracking the resource's state

confirm that the resources you expected are imported into the state by running 
``` hcl 
terraform state list
```

#### 7) Remove old files from the state file

If you clean out the entire state file and the terraform state list returns nothing than you can just delete the blob associated with that state workspace instead of running the below resources. DO NOT LEAVE THE SAME RESOURCE IN MULTIPLE STATE FILES this will cause all sorts of wild terraform behavior that will be incredibly difficult to track down.

in the state file you want to stop managing a resource's state run
``` hcl
terraform state rm terraformID
```

confirm that the resources you expected are cleaned up by running 
``` hcl 
terraform state list
```
Note this will not destroy the resource this will just tell terraform to stop tracking the resource's state

#### 8) Test migration worked 

run a terraform init and plan (Do not run the terraform apply) with the new state files. If your plan says 
``` hcl
No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration
and found no differences, so no changes are needed.
```
then you did it correctly - Congrats you just manually managed Terraform state!

Cleanup
ManagementGroupstate.tfstateenvManagementGroup
ManagementGroupstate.tfstate


#### Common Errors
1) Error Backend configuration changed
``` hcl
│ Error Backend configuration changed
│
│ A change in the backend configuration has been detected, which may require migrating existing state.
│
│ If you wish to attempt automatic migration of the state, use terraform init -migrate-state.
│ If you wish to store the current configuration with no changes to the state, use terraform init -reconfigure.
```

run the below command

``` hcl
terraform init -reconfigure
```
2) Error multiple Aliases for Subscription 

``` hcl
Error multiple Aliases for Subscription  already exist - to be managed via Terraform only one Alias can exist and this resource needs to be imported into the State. Please see the resource documentation for azurerm_subscription for more information
``` 

httpsdiscuss.hashicorp.comtproblems-managing-subscriptions-with-aliases361112
to get the exiting alias use
``` az cli
az account alias list 
```