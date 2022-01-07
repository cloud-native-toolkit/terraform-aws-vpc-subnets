output "vpc_id" {
  description = "Description of my output"
  value       = "value"
  #depends_on  = [<some resource>]
}
output "public_subnet_ids" {
   value = data.aws_subnets.public_subnet_ids.ids  
#  value = [for s in data.aws_subnet.public_subnet_id : 
#  {"id" = s.id,"cidr_block"=s.cidr_block, "availability_zone" =s.availability_zone}]
}

output "private_subnet_ids" {
  value = data.aws_subnets.private_subnet_ids.ids
  # value = [for s in data.aws_subnet.private_subnet_id : 
  # {"id" = s.id,"cidr_block"=s.cidr_block, "availability_zone" =s.availability_zone}]
}

# output "public_subnet_cidrs" {
#   value = [for s in data.aws_subnet.public_subnet_id : s.cidr_block]
# }
  
# output "private_subnet_cidrs" {
#   value = [for s in data.aws_subnet.private_subnet_id : s.cidr_block]
# }


