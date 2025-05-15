module "subnets" {
  source = "git::https://github.com/nasir19noor/terraform.git//aws/modules/subnet?ref=main"
  
  region        = local.region
  vpc_id        = local.vpc_id
  subnet_count  = local.subnet_count
  cidr_blocks   = local.cidr_blocks
  map_public_ip_on_launch = true
  # tags = {
  #   Name        = "nasir-eks-subnet-${count.index}"
  # }
}