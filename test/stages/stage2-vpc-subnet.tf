module "dev_vpc_subnet" {
  source                          = "./module"
  vpc_id                          = module.dev_vpc.vpc_id
  private_subnet_cidr             = var.private_subnet_cidr
  public_subnet_cidr              = var.public_subnet_cidr
  availability_zones              = var.availability_zones
  map_customer_owned_ip_on_launch = false
  map_public_ip_on_launch         = false
  tags                            = var.tags
  public_subnet_tags              = var.public_subnet_tags
  private_subnet_tags             = var.private_subnet_tags

}
