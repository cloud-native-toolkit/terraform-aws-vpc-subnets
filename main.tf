/* Steps to create AWS Subnet :
  Input - VPC_ID
  Default_network ACL id
  prefix_name
********

*/

locals {
  #vpc_subnet_name        = var.name != "" ? var.name : "${var.prefix_name}-vpc-subnet"
  
  num_of_public_sn_cidrs  = length(var.public_subnet_cidr)
  num_of_private_sn_cidrs = length(var.private_subnet_cidr)
  num_of_availability_zones = length(var.availability_zones)
  nat_gateway_count = 1
  gateway_id             = var.provision_igw  ? aws_internet_gateway.internet_gw[0].id : var.igw_id
}
#############################
# Internet Gateway
#############################
resource "aws_internet_gateway" "internet_gw" {
  count = var.provision_igw && ((length(var.public_subnets) > 0) || local.num_of_public_sn_cidrs > 0) ? 1 : 0
  vpc_id = var.vpc_id

  tags = merge(
    {
      "Name" = format("${var.prefix_name}-%s-%s", var.vpc_id, "igw")
    }
    ,
    var.tags
  )
}

##################################################
# Public Subnet
##################################################
resource "aws_subnet" "public_subnet" {
  count = local.num_of_public_sn_cidrs > 0 ? local.num_of_public_sn_cidrs : 0

  vpc_id                  = var.vpc_id
  cidr_block              = element(var.public_subnet_cidr, count.index)
  availability_zone       = local.num_of_availability_zones > 0 ? element(var.availability_zones, count.index) : null
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    {
      "Name" = format(
        "${var.prefix_name}-%s-%s",
        "public-subnet",
        element(var.availability_zones, count.index)
      )
    },
    var.tags,
    var.public_subnet_tags
  )
}
####################################
# Add network ACL for each public subnet 
# implement the logic by adding rules for each specific subnet
#  ??????? steps below
####################################

##################################################
# Add Route table and Routes  for Public Subnet
# 1. Create Route table
# 2. Create routes for the public subnet and IGW
##################################################
resource "aws_route_table" "public_rt" {
  count = local.num_of_public_sn_cidrs > 0 ? 1 : 0
  vpc_id = var.vpc_id
  tags = merge(
    {
      "Name" = format("${var.prefix_name}-%s", "public-rt")
    }
    ,
    var.tags
  )
}

resource "aws_route" "public_ig_route" {
  depends_on = [
    aws_internet_gateway.internet_gw
  ]
  count                  = var.provision_igw || local.num_of_public_sn_cidrs > 0 ? 1 : 0
  route_table_id         = aws_route_table.public_rt[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = local.gateway_id

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
  count = local.num_of_public_sn_cidrs > 0 ? local.num_of_public_sn_cidrs : 0

  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_rt[0].id
}


##################################################
# Private Subnet
##################################################

resource "aws_subnet" "private_subnet" {
  count      = local.num_of_private_sn_cidrs > 0 ? local.num_of_private_sn_cidrs : 0
  vpc_id     = var.vpc_id
  cidr_block = var.private_subnet_cidr[count.index]
  availability_zone = local.num_of_availability_zones > 0 ? element(var.availability_zones, count.index) : null
  timeouts {
    create = "10m"
    delete = "20m"
  }
  tags = merge(
    {
      "Name" = format(
        "${var.prefix_name}-%s-%s",
        "private-subnet",
        element(var.availability_zones, count.index)
      )
    },
    var.tags,
    var.private_subnet_tags
  )
}

# data "aws_vpc" "vpc" {
#   depends_on = [
#     aws_subnet.private_subnet
#   ]
#   id = var.vpc_id
# }
# output "vpc" {
#   value = data.aws_vpc.vpc
# }

####################################################
# Private subnet Route table and Routes
# 1. Create Private route table
# 2. Create Route between subnet and nat gateway
####################################################
resource "aws_route_table" "private_rt" {
  count = local.num_of_private_sn_cidrs > 0 ? local.nat_gateway_count : 0
  vpc_id = var.vpc_id
  tags = merge(
    {
      "Name" = format(
        "${var.prefix_name}-%s-%s",
        "private-route",
        element(var.availability_zones, count.index),
      )
    }
    # ,
    # var.tags,
    # var.private_route_table_tags,
  )
}

resource "aws_route_table_association" "private_rt_assoc" {
  count = local.num_of_private_sn_cidrs > 0 ? local.num_of_private_sn_cidrs : 0
  subnet_id = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = element(
    aws_route_table.private_rt.*.id, count.index,
  )
}
##########################################################
# Create NAT Gateway
# For Public NAT gateway, create Elastic IP and add to Nat Gw
##########################################################


resource "aws_eip" "nat_gw_eip" {
  count = var.provision_ngw ? local.nat_gateway_count : 0
  vpc = true
  tags = merge(
    {
      "Name" = format(
        "%s-%s",
        var.prefix_name,
        "nat-gw-public-eip",
      )
    }
    # ,
    # var.tags,
    # var.nat_eip_tags,
  )
}

resource "aws_nat_gateway" "nat_gw_public" {
  count = var.provision_ngw ? 1 : 0
  allocation_id = aws_eip.nat_gw_eip[0].id
  subnet_id = element(
    aws_subnet.public_subnet.*.id, count.index,
  )
  tags = merge(
    {
      "Name" = format(
        "%s-%s",
        var.prefix_name,
        "nat-gw-pub",
      )
    }
    # ,
    # var.tags,
    # var.nat_gateway_tags,
  )
  depends_on = [aws_internet_gateway.internet_gw]
}

resource "aws_route" "private_nat_gw-route" {
  count = var.provision_ngw ? local.nat_gateway_count : 0
  route_table_id         = element(aws_route_table.private_rt.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         =aws_nat_gateway.nat_gw_public[0].id
  timeouts {
    create = "5m"
  }
}


data "aws_subnets" "public_subnet_ids" {
  depends_on = [
    aws_subnet.public_subnet
  ]
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  tags = {
    tier = "public"
  }
}

# data "aws_subnet" "public_subnet_id" {
#   depends_on = [
#     aws_subnet.public_subnet
#   ]
#   for_each = toset(data.aws_subnets.public_subnet_ids.ids)
#   id       = each.value
# }

data "aws_subnets" "private_subnet_ids" {
  depends_on = [
    aws_subnet.private_subnet
  ]
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  tags = {
    tier = "private"
  }
}

# data "aws_subnet" "private_subnet_id" {
#   depends_on = [ 
#     data.aws_subnets.private_subnet_ids
#   ]
#   for_each = toset(data.aws_subnets.private_subnet_ids.ids)
#   id       = each.value
# }

