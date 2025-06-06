locals {
  config                  = yamldecode(file("../../config.yaml"))
  region                  = local.config.global.region
  bucket                  = local.config.global.state_bucket
  vpc_id                  = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_cidr_block          = data.terraform_remote_state.vpc.outputs.vpc_cidr_block
  subnet-1_id             = data.terraform_remote_state.subnet.outputs.subnet_ids[0]
  subnet-2_id             = data.terraform_remote_state.subnet.outputs.subnet_ids[1]
  igw_id                  = data.terraform_remote_state.vpc.outputs.igw_id
  name                    = local.config.eks.cluster_name
  cluster_version         = local.config.eks.cluster_version
  create_cluster_security_group = true
  create_node_security_group    = true 
}    