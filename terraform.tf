terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-dev-001"   //var.resource_group_name
    storage_account_name = "stdevterraformstate002" //var.storage_account_name
    container_name       = "jenkinsstate"           //var.container_name
    key                  = "terraform.tfstate"
  }
}

data "terraform_remote_state" "resource_group" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-terraform-dev-001"
    storage_account_name = "stdevterraformstate002"
    container_name       = "bootstrapstate"
    key                  = "terraform.tfstate"
  }
}