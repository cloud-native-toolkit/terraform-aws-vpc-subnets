output "vpc_id" {
  value  = local.vpc_id
}


output "ids" {
  #value = data.aws_subnets.subnet_ids.ids
  value= aws_subnet.subnet.*.id
}
output "count" {
value = local.num_of_sn_cidrs
}

output "route_table_ids" {
  #value = data.aws_subnets.subnet_ids.ids
  value = aws_route_table.subnet_rt.*.id
}

#Remove below 2 outputs after testing all archs.  Reason- Having subnet as prefix.  
#Currently keeping it for making sure other modules doesn't break
output "subnet_ids" {
  #value = data.aws_subnets.subnet_ids.ids
  value= aws_subnet.subnet.*.id
}

output "subnet_count" {
value = local.num_of_sn_cidrs
}

