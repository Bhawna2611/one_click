variable "vpc_id" {}

variable "private_subnets" {
  type = list(string)
}

variable "tg_arn" {}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {}

variable "user_data" {
  default = ""
}

variable "app_port" {
  type = number
}

variable "bastion_sg_id" {}

variable "alb_sg_id" {}

variable "asg_name" {
  description = "Name for the Auto Scaling Group"
  type        = string
  default     = "mysql-asg"
}

variable "common_tags" {
  type = map(string)
}
