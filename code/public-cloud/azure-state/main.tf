terraform {
  required_version = ">= 1.1.3"
  required_providers {

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.38.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "= 2.1.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "pkslow-tstate-rg"
    storage_account_name = "pkslowtfstate"
    container_name       = "tfstate"
    key                  = "pkslow.tfstate"
  }
}

provider "azurerm" {
  features {}
}

resource "local_file" "test-file" {
  content  = "https://www.pkslow.com"
  filename = "${path.root}/terraform-guides-by-pkslow.txt"
}