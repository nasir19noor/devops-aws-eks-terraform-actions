data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = local.bucket
    key    = "vpc/terraform.tfstate"
    region = local.region
  }
}

data "terraform_remote_state" "subnet" {
  backend = "s3"
  config = {
    bucket = local.bucket
    key    = "subnet/terraform.tfstate"
    region = local.region
  }
}



