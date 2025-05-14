locals {
  config                  = yamldecode(file("../../config.yaml"))
  region                  = local.config.global.region
  bucket                  = local.config.global.state_bucket
}    