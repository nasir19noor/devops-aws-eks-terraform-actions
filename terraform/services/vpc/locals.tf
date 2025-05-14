locals {
  config                  = yamldecode(file("../../config.yaml"))
  cidr_block              = local.config.network.cidr_block
  region                  = local.config.global.region
  name                    = local.config.network.vpc_name
  description             = local.config.network.description
  instance_tenancy        = local.config.network.instance_tenancy
  enable_dns_hostnames    = local.config.network.enable_dns_hostnames
  enable_dns_support      = local.config.network.enable_dns_support
}    

