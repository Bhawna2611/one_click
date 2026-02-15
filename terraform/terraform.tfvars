ami_id        = "ami-0c398cb65a93047f2"
instance_type = "t2.micro"
key_name      = "one__click"
ssh_cidr      = ["0.0.0.0/0"]

common_tags = {
  Project     = "terraform-assignment"
  Environment = "dev"
  Owner       = "bhawna"
}

vpc_cidr      = "10.0.0.0/16"
public_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
alb_name      = "mysql-alb"
asg_name      = "mysql-asg"
ansible_user  = "ubuntu"
ssh_key_path  = "/tmp/one__click.pem"
alb_port      = 80
vpc_name      = "mysql-vpc"
igw_name      = "mysql-igw"
nat_name      = "mysql-nat"
