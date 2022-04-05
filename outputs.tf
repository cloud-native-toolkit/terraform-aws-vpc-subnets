output "vpc_id" {
  value  = local.vpc_id
}

output "subnet_ids" {
  #value = data.aws_subnets.subnet_ids.ids
  value= aws_subnet.subnet.*.id
}

output "ids" {
  #value = data.aws_subnets.subnet_ids.ids
  value= aws_subnet.subnet.*.id
}

output "subnet_count" {
value = local.num_of_sn_cidrs
}

output "count" {
value = local.num_of_sn_cidrs
}
