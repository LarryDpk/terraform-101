terraform {
  required_version = ">= v1.0.11"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "= 2.1.0"
    }
  }

  backend "pg" {
    conn_str = "postgres://pkslow:pkslow@localhost:5432/terraform?sslmode=disable"
  }
}

resource "local_file" "test-file" {
  content  = "https://www.pkslow.com"
  filename = "${path.root}/terraform-guides-by-pkslow.txt"
}