locals {
  install_script = file("${path.module}/install.sh")
}


variable "environment" {
    type = string
    default = "dev"
  
}