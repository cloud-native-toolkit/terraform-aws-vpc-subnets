output "vpc_id" {
  description = "Description of my output"
  value       = "value"
}
output "public_subnet_ids" {
   value = data.aws_subnets.public_subnet_ids.ids  
}

output "private_subnet_ids" {
  value = data.aws_subnets.private_subnet_ids.ids
}

output "subnet_count_public" {
value = local.num_of_public_sn_cidrs
}

output "subnet_count_private" {
value = local.num_of_private_sn_cidrs
}



