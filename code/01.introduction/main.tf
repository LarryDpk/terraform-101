terraform {
  required_version = ">= v1.0.11"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "= 2.1.0"
    }
  }
}

resource "local_file" "terraform-introduction" {
  content  = "Hi guys, this the tutorial of Terraform from pkslow.com"
  filename = "${path.module}/terraform-introduction-by-pkslow.txt"
}