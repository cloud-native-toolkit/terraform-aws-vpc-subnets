output "vpc_id" {
  depends_on = [
    module.dev_vpc
  ]
  value = module.dev_vpc.vpc_id

}

output "public_subnet_ids" {
  depends_on = [
    module.dev_vpc_subnet
  ]
  value = module.dev_vpc_subnet.public_subnet_ids

}
output "private_subnet_ids" {
  depends_on = [
    module.dev_vpc_subnet
  ]
  value = module.dev_vpc_subnet.private_subnet_ids
}

output "subnet_ids" {
  # depends_on = [
  #   module.dev_vpc_subnet
  # ]
  value = module.dev_vpc_subnet.subnet_ids
}