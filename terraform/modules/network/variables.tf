variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "public_cidrs" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
}

variable "private_cidrs" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "vpc_name" {
  description = "Name for the VPC"
  type        = string
}

variable "igw_name" {
  description = "Name for the Internet Gateway"
  type        = string
}

variable "nat_name" {
  description = "Name for the NAT Gateway"
  type        = string
}
