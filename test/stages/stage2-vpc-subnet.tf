module "dev_pub_subnet" {
  source = "./module"
  provision=var.provision
  region = var.region
  name_prefix = var.name_prefix
  label = "public"
  vpc_name = module.dev_vpc.vpc_name
  subnet_cidrs = var.pub_subnet_cidrs
  multi-zone = var.multi-zone
  #availability_zones  = var.availability_zones
  # acl_rules = var.acl_rules_pub
  # map_customer_owned_ip_on_launch = false
  # map_public_ip_on_launch         = false
  
  gateways = [module.dev_igw.igw_id]
  
}

# module "dev_ngw" {
#     source = "./ngw"
#    #source = "github.com/cloud-native-toolkit/terraform-aws-nat-gateway"

#     _count = var.cloud_provider == "aws" ? 2 : 0
#     provision = var.provision
#     resource_group_name = var.resource_group_name
#     name_prefix = var.name_prefix
#     connectivity_type = var.connectivity_type
#     #allocation_id = var.allocation_id
#     subnet_ids = module.dev_pub_subnet.subnet_ids     
#     #subnet_ids= var.subnet_ids    
# }

module "dev_priv_subnet" {
  source = "./module"
  depends_on = [
      module.dev_vpc,
      module.dev_igw
  ]
  provision=var.provision
  region=var.region
  name_prefix = var.name_prefix
  label = "private"
  vpc_name = module.dev_vpc.vpc_name
  subnet_cidrs = var.priv_subnet_cidrs
  #multi-zone = var.multi-zone
  #availability_zones = var.availability_zones
  #acl_rules = var.acl_rules_pri
  #map_customer_owned_ip_on_launch = false
  #map_public_ip_on_launch         = false
  
  #gateways = module.dev_ngw.ngw_id  
  
}