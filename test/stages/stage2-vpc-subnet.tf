module "dev_pub_subnet" {
  source = "./module"
  provision=var.provision
  name_prefix = var.name_prefix

  label = "public"
  vpc_name                         = module.dev_vpc.vpc_name
  #subnet_cidrs              = ["10.0.0.0/20","10.0.125.0/24"]
  #availability_zones              = ["ap-south-1a","ap-south-1b"]
  subnet_cidrs = var.pub_subnet_cidrs
  availability_zones  = var.availability_zones
  gateways = [module.dev_igw.igw_id]
  map_customer_owned_ip_on_launch = false
  map_public_ip_on_launch         = false
  acl_rules = var.acl_rules_pub
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
  name_prefix = var.name_prefix

  label = "private"
  vpc_name = module.dev_vpc.vpc_name
  #subnet_cidrs = ["10.0.128.0/20","10.0.144.0/20"]
  #availability_zones = ["ap-south-1a","ap-south-1b"]
  subnet_cidrs = var.priv_subnet_cidrs
  availability_zones = var.availability_zones
  map_customer_owned_ip_on_launch = false
  map_public_ip_on_launch         = false
  acl_rules = var.acl_rules_pri
  #gateways = module.dev_ngw.ngw_id  
  
}