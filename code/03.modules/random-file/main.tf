resource "random_string" "random" {
  length  = 6
  lower   = true
  special = false
}

resource "local_file" "file" {
  content  = var.content
  filename = "${path.root}/.result/${var.prefix}.${random_string.random.result}.txt"
}