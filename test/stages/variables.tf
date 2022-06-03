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
variable "cloud_provider" {
  type = string
  default = "aws"
}
variable "provision" {
  type        = bool
  description = "Flag indicating that the instance should be provisioned. If false then an existing instance will be looked up"
  default     = true
}

variable "resource_group_name" {
  type        = string
  description = "Existing resource group where the IKS cluster will be provisioned."
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
variable "instance_tenancy" {
  type        = string
  description = "Instance is shared / dedicated, etc. #[default, dedicated, host]"
  default     = "default"
}
variable "internal_cidr" {
  type        = string
  description = "The cidr range of the internal network.Either provide manually or chose from AWS IPAM poolsß"
  default     = "10.0.0.0/16"
}
variable "vpc_id" {
  type        = string
  description = "The id of the existing VPC instance"
  default     = ""
}
variable "subnet_count" {
  type        = number
  description = "Numbers of subnets to provision"
  default     = 0
}
variable "pub_subnet_cidrs" {
  type        = list(string)
  description = "The cidr range of the Public subnet."
  #default=["10.0.0.0/20"]
}
variable "priv_subnet_cidrs" {
  type        = list(string)
  description = "The cidr range of the Private subnet."
  #default=["10.0.128.0/20"]
}

variable "multi-zone" {
  type = bool
  default = true
  description = "Create subnets in multiple zones"
}

variable "availability_zones" {
  description = "List of availability zone ids"
  type        = list(string)
  default     = []
}
variable "acl_rules_pub" {
  type        = list(map(string))
  default = []
}
variable "acl_rules_pri" {
  description = "Private subnets inbound network ACLs"
  type        = list(map(string))
  default = []
}
variable "gateways" {
  type = list(string)
  description = "List of gateway ids and zones"
  default     = []
}
# variable "connectivity_type" {
#   type        = string
#   description = "(Optional) Connectivity type for the gateway. Valid values are private and public. Defaults to public."
#   default     = "public"    
# }