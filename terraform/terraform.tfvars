ami_id        = "ami-0c398cb65a93047f2"
instance_type = "t2.micro"
key_name      = "one__click"
ssh_cidr      = ["0.0.0.0/0"]

common_tags = {
  Project     = "terraform-assignment"
  Environment = "dev"
  Owner       = "bhawna"
}
