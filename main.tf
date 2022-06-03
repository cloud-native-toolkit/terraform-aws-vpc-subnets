locals {

  resource_group_name = var.resource_group_name != "" && var.resource_group_name != null ? var.resource_group_name : "default"
  num_of_sn_cidrs  = length(var.subnet_cidrs)
  
  gateway_count      = length(var.gateways)
  vpc_id = var.provision ? data.aws_vpc.vpc[0].id : null
  az_names =["a","b","c"]
  availability_zones =  length(var.availability_zones)>0 ? var.availability_zones: [ for index in range(local.num_of_sn_cidrs): "${var.region}${local.az_names[index]}" ]
  num_of_availability_zones = var.multi-zone && length(var.availability_zones) >0 ? length(var.availability_zones) : (var.multi-zone ? local.num_of_sn_cidrs : 1) 


  default_acl_rules = [
    {
      rule_number = 100
      rule_action = "allow"
      egress = false      
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number = 100
      rule_action = "allow"
      egress = true
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
] 

acl_rules =  length(var.acl_rules) > 0 ? var.acl_rules : local.default_acl_rules
}

resource null_resource print_names {
  count = var.provision ? 1 : 0

  provisioner "local-exec" {
    command = "echo 'VPC name: ${var.vpc_name != null && var.vpc_name != "" && var.vpc_name != null ? var.vpc_name : null}'"
  }
}

data "aws_vpc" "vpc" {
  depends_on = [
    null_resource.print_names
  ]
  count = var.provision ? 1 : 0

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "subnet" {
  count = (var.provision && local.num_of_sn_cidrs > 0) ? local.num_of_sn_cidrs : 0
  vpc_id                  = local.vpc_id
  cidr_block              = element(var.subnet_cidrs, count.index)
  #availability_zone       = local.num_of_availability_zones > 0 ? element(var.availability_zones, count.index) : null
  availability_zone       = local.num_of_availability_zones > 0 ? (var.multi-zone ? element(local.availability_zones, count.index):  element(local.availability_zones, 0)) : null
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags ={
      "Name" = format(
        "${var.name_prefix}-%s-%s-%s",
        "${var.label}",
        #element(var.availability_zones, count.index)
        #element(local.availability_zones, count.index)
        local.num_of_availability_zones > 0 ? (var.multi-zone ? element(local.availability_zones, count.index):  element(local.availability_zones, 0)) : null,
        count.index
      ),
      ResourceGroup = local.resource_group_name,
      tier =  "${var.label}"
    }  
}


#Creare ACL group for the subnets. All subnets passed as inputs attached to same ACL group
resource "aws_network_acl" "subnet_acl" {
  depends_on = [aws_subnet.subnet]
  count = (var.provision && local.num_of_sn_cidrs > 0) ? 1 : 0
  vpc_id     = local.vpc_id
  subnet_ids = aws_subnet.subnet[*].id
  tags = {
      "Name" = format(
        "${var.name_prefix}-%s",
        "${var.label}-sn-acl"
      ),
      ResourceGroup = local.resource_group_name
    }
  
}

resource "aws_network_acl_rule" "subnet_acl" {
  #count = (var.provision && local.num_of_sn_cidrs > 0)  ? length(var.acl_rules) : 0
  count = (var.provision && local.num_of_sn_cidrs > 0)  ? length(local.acl_rules) : 0
  network_acl_id = aws_network_acl.subnet_acl[0].id
  rule_number    = local.acl_rules[count.index]["rule_number"]
  egress = local.acl_rules[count.index]["egress"]
  protocol       = local.acl_rules[count.index]["protocol"]
  rule_action    = local.acl_rules[count.index]["rule_action"]
  cidr_block     = local.acl_rules[count.index]["cidr_block"]
  from_port      = local.acl_rules[count.index]["from_port"]
  to_port        = local.acl_rules[count.index]["to_port"]
  
}

##################################################
# Add Route table and Routes  for Public Subnet
# 1. Create Route table
# 2. If pub subnet, create routes for the public subnet and IGW
# 2. If private subnet, create routes for the public subnet and IGW
##################################################

resource "aws_route_table" "subnet_rt" {
  count = (var.provision && local.num_of_sn_cidrs > 0) ? local.num_of_sn_cidrs : 0
  vpc_id = local.vpc_id
  
  tags = {
      "Name" = format(
        "${var.name_prefix}-%s-%s",
        "${var.label}-sn-rt",
        #element(var.availability_zones, count.index),
        element(local.availability_zones, count.index),
      ),
      ResourceGroup = local.resource_group_name
    }  
}

resource "aws_route_table_association" "subnet_rt_assoc" {
  depends_on = [aws_route_table.subnet_rt]
  count = (var.provision && local.num_of_sn_cidrs > 0) ? local.num_of_sn_cidrs : 0
  subnet_id      = element(aws_subnet.subnet.*.id, count.index)
  route_table_id = element(aws_route_table.subnet_rt.*.id, count.index)

}

resource "aws_route" "public_igw_route" {
  depends_on = [aws_route_table.subnet_rt]
  count = (var.provision && var.label== "public" && local.num_of_sn_cidrs > 0) ?  local.num_of_sn_cidrs : 0
  route_table_id         = element(aws_route_table.subnet_rt.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = element(var.gateways, 0)
  timeouts {
    create = "5m"
  }
}
resource "aws_route" "private_ngw-route" {
  depends_on = [aws_route_table.subnet_rt]

  count = (var.provision && var.label== "private" && local.num_of_sn_cidrs > 0 && length(var.gateways) > 0 ) ? local.num_of_sn_cidrs : 0
  route_table_id         = element(aws_route_table.subnet_rt.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id =  element(var.gateways, count.index)
  timeouts {
    create = "5m"
  }
}



# data "aws_subnets" "subnet_ids" {
#   depends_on = [
#     aws_subnet.subnet,    
#   ]
#   filter {
#     name   = "vpc-id"
#     values = [local.vpc_id]
#   } 
#   tags = {
#     tier =  "${var.label}"
#     ResourceGroup = local.resource_group_name
#   }  
# }


