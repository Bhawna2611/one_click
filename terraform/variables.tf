variable "region" {
  default = "us-east-1"
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  type = string
}

variable "ssh_cidr" {
  type = list(string)
}


variable "common_tags" {
  type = map(string)
}
