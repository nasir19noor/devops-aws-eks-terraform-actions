resource "aws_route_table" "public" {
 vpc_id = local.vpc_id
 
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = local.igw_id
 }
 
 tags = {
   Name = "public-route-table"
 }
}


resource "aws_route_table_association" "public_subnet_asso" {
 count = local.subnet_count
 subnet_id      = element(module.subnets.subnet_ids, count.index)
 route_table_id = aws_route_table.public.id
}

