/* Remove later */

variable "region" {
  type        = string
  default     = "ap-south-1"
  description = "Please set the region where the resouces to be created "
}

variable "access_key" {
  type = string
}
variable "secret_key" {
  type = string
}

/* Remove later end */


/*module specific variables */
# variable "subnet_type" {
#   type        = string
#   description = "Type of the subnet: Public / Private"
#   default     = "private"
# }

variable "prefix_name" {
  type        = string
  description = "Prefix to be added to the names of resources which are being provisioned"
  default     = "swe"
}

variable "provision_igw" {
  type        = bool
  description = "Provision Internet Gateway based if true."
  default     = true
}

variable "igw_id" {
  type        = string
  description = "Id of the internet gateway associated with VPC."
  default     = ""
}


/* Resource level variables */
variable "vpc_id" {
  type        = string
  description = "(Required) The VPC ID."
  default     = ""
}

# variable "cidr_block" {
#   type        = string
#   description = "(Required) The CIDR block for the subnet."
#   default     = "10.0.0.0/16"
# }

variable "private_subnet_cidr" {
  type        = list(string)
  description = "(Required) The CIDR block for the private subnet."
  default     = ["10.0.125.0/24"]
}

variable "public_subnet_cidr" {
  type        = list(string)
  description = "(Required) The CIDR block for the public subnet."
  default     = ["10.0.0.0/20"]
}
variable "availability_zones" {
  description = "List of availability zone ids"
  type        = list(string)
  default     = [""]
}

# variable "availability_zone_id" {  
#   type        = string
#   description = " (Optional) The AZ ID of the subnet."

# }


variable "customer_owned_ipv4_pool" {
  type        = string
  description = "Type of the subnet: Public / Private"
  default     = ""
}

variable "map_customer_owned_ip_on_launch" {
  type        = string
  description = "Specify true to indicate that network interfaces created in the subnet should be assigned a customer owned IP address. The customer_owned_ipv4_pool and  arguments must be specified when set to true. Default is false."
  default     = false 
}

variable "map_public_ip_on_launch" {
  type        = string
  description = "(Optional) Specify true to indicate that instances launched into the subnet should be assigned a public IP address. Default is fals"
  default     = false
}

variable "tags" {
  type        = map(string)
  default     = {
    project = "swe"
  }
  description = "(Optional) A map of tags to assign to the resource. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level."
}

variable "public_subnet_tags" {
  description = "Tags for public subnets"
  type        = map(string)
  default     = {
    tier = "public"
  }
}

variable "private_subnet_tags" {
  description = "Tags for private subnets"
  type        = map(string)
  default     = {
    tier = "private"
  }
}

variable "public_subnets" {
  description = "List of Public subnets in VPC"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "List of Private subnets in VPC"
  type        = list(string)
  default     = []
}

### For NAT gateway ####################################
# subnet_id - (Required)
# allocation_id, connectivity_type, tags - Optional
########################################################
variable "allocation_id" {
  description = "(Optional) The Allocation ID of the Elastic IP address for the gateway. Required for connectivity_type of public."
  type        = string
  default     = ""
}

variable "connectivity_type" {
  description = "(Optional) Connectivity type for the gateway. Valid values are private and public. Defaults to public."
  type        = string
  default     = "public"
}

### module specific 
variable "provision_ngw" {
  description = ""
  type        = bool
  default     = true
}

