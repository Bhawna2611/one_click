variable "vpc_id" {
  description = "VPC ID for ALB"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "alb_name" {
  description = "ALB Name"
  type        = string
  default     = "mysql-alb"
}

variable "alb_port" {
  description = "ALB Listener Port"
  type        = number
  default     = 80
}

variable "common_tags" {
  description = "Tags for ALB"
  type        = map(string)
}
