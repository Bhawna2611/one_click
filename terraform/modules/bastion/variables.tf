variable "vpc_id" {}

variable "public_subnet_id" {}

variable "ami_id" {}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {}

variable "ssh_cidr" {
  type = list(string)
}

variable "common_tags" {
  type = map(string)
}

variable "ssh_key_path" {
 description = "Path to the private key for copying to bastion host"
 type        = string
}
