output "vpc_id" {
  value  = local.vpc_id
}

output "subnet_ids" {
  value = data.aws_subnets.subnet_ids.ids
}

output "subnet_count" {
value = local.num_of_sn_cidrs
}
