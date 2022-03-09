variable "provision" {
  type        = bool
  description = "Provision Subnet if  true."
  default     = true
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group where the VPC is deployed. On AWS this value becomes a tag."
  default     = "default"
}

variable "name_prefix" {
  type        = string
  description = "Prefix to be added to the names of resources which are being provisioned"
  default     = "swe"
}

variable "label" {
  type        = string
  description = "label to define type of subnet"
  default     = "private"
}

variable "gateways" {
  type = list(string)
  description = "List of gateway ids and zones"
  default     = []
}

variable "vpc_name" {
  type        = string
  description = "(Required) The VPC name."
  default     = ""
}

variable "subnet_cidrs" {
  type        = list(string)
  description = "(Required) The CIDR block for the  subnet."
  default     = []
}

variable "availability_zones" {
  description = "List of availability zone ids"
  type        = list(string)
  default     = []
}

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


# variable "public_subnets" {
#   description = "List of Public subnets in VPC"
#   type        = list(string)
#   default     = []
# }

# variable "private_subnets" {
#   description = "List of Private subnets in VPC"
#   type        = list(string)
#   default     = []
# }

variable "allocation_id" {
  description = " For NAT Gateway. Required if connectivity_type is public."
  type        = string
  default     = "" 
}

variable "connectivity_type" {
  description = "For NAT Gateway. Valid values are private and public. Defaults to public."
  type        = string
  default     = "public"
}

variable "acl_rules" {
  type        = list(map(string))
  default = []
}