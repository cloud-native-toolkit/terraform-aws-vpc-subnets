output "vpc_id" {
  depends_on = [
    module.dev_vpc
  ]
  value = module.dev_vpc.vpc_id

}
output "vpc_name" {
  depends_on = [
    module.dev_vpc
  ]
  value = module.dev_vpc.vpc_name
}

output "public_subnet_ids" {
  depends_on = [
    module.dev_pub_subnet
  ]
  value = module.dev_pub_subnet.subnet_ids

}


output "private_subnet_ids" {
  depends_on = [
    module.dev_priv_subnet
  ]
  value = module.dev_priv_subnet.subnet_ids
}


# output "ngw_id" {   
#     value = module.dev_ngw.ngw_id
# }

# output "allocation_id" {   
#     value = module.dev_ngw.allocation_id 
#     description = "The Allocation ID of the Elastic IP address for the gateway."
# }
 
# output "subnet_id" {   
#     value = module.dev_ngw.subnet_id     
# }

# output "network_interface_id" {    
#     value = module.dev_ngw.network_interface_id 
# }

# output "private_ip" {    
#     value = module.dev_ngw.private_ip 
#     description = "The private IP address of the NAT Gateway."
# }
# output "public_ip" {    
#     value = module.dev_ngw.public_ip 
#     description = "The public IP address of the NAT Gateway."
# }