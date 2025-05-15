terraform {
  backend "s3" {
    key = "subnet/terraform.tfstate"
  }
}