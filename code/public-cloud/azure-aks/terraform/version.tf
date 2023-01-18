terraform {
  required_version = ">= 1.1.3"
  required_providers {

    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.38.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "= 3.1.0"
    }
  }
}