locals {
  config                  = yamldecode(file("../../config.yaml"))
  region                  = local.config.global.region
  bucket                  = local.config.global.state_bucket
  subnet_count            = local.config.network.subnet_count
  subnet_mask             = local.config.network.subnet_mask
  vpc_id                  = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_cidr_block          = data.terraform_remote_state.vpc.outputs.vpc_cidr_block
  igw_id                  = data.terraform_remote_state.vpc.outputs.igw_id
  cidr_blocks = [
    for i in range(local.subnet_count) :
    cidrsubnet(local.vpc_cidr_block, local.subnet_mask - tonumber(split("/", local.vpc_cidr_block)[1]), i + 1)
  ]
}    