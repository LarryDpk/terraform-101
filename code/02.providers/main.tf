terraform {
  required_version = ">= v1.0.11"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "= 2.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
  }
}