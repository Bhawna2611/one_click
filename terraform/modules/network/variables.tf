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
