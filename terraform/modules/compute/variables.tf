variable "vpc_id" {}
variable "public_subnet_id" {}
variable "private_subnet_id" {}
variable "instance_type" { default = "t2.micro" }



variable "common_tags" {
  description = "Universal tags applied to all resources"
  type        = map(string)
  default     = {
    Project     = "Cloud-Deployment"
    Environment = "Dev"
    Owner       = "DevOps-Team"
  }
}

variable "public_instance_name" {
  type    = string
  default = "public-ubuntu-server"
}

variable "private_instance_name" {
  type    = string
  default = "private-ubuntu-server"
}
