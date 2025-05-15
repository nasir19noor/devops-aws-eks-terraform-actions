output "subnet_ids" {
  description = "List of IDs of the data subnets"
  value       = module.subnets.subnet_ids
}

output "subnet_arns" {
  description = "List of ARNs of the data subnets"
  value       = module.subnets.subnet_arns
}

output "subnet_cidr_blocks" {
  description = "List of CIDR blocks of the data subnets"
  value       = module.subnets.subnet_cidr_blocks
}

output "subnet_availability_zones" {
  description = "List of availability zones of the data subnets"
  value       = module.subnets.subnet_availability_zones
}

output "subnet_ids_by_az" {
  description = "Map of availability zones to data subnet IDs"
  value       = module.subnets.subnet_ids_by_az
}

output "subnet_cidr_blocks_by_az" {
  description = "Map of availability zones to data subnet CIDR blocks"
  value       = module.subnets.subnet_cidr_blocks_by_az
}

output "subnet_vpc_id" {
  description = "The VPC ID where the data subnets were created"
  value       = module.subnets.vpc_id
}

output "subnet_count" {
  description = "Number of data subnets created"
  value       = module.subnets.subnet_count
}

output "subnet_by_index" {
  description = "Map of subnet index to subnet details"
  value = {
    for i, id in module.subnets.subnet_ids : i => {
      id            = id
      arn           = module.subnets.subnet_arns[i]
      cidr_block    = module.subnets.subnet_cidr_blocks[i]
      az            = module.subnets.subnet_availability_zones[i]
    }
  }
}

output "subnet_named_map" {
  description = "Map of subnet names to subnet IDs"
  value = {
    for i, id in module.subnets.subnet_ids : 
      "subnet-${i+1}" => id
  }
}

output "route_table_id" {
  description = "route table id"
  value       = aws_route_table.public.id
}