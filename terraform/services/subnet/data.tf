data "terraform_remote_state" "vpc" {
  backend = "s3" 
  config = {
    bucket = local.bucket
    key = "vpc/terraform.tfstate" 
    region = local.region
  }
}
