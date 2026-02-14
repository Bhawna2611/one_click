########################
# Ubuntu 22.04 AMI
########################
data "aws_ami" "ubuntu_22" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

########################
# Security Group (Private EC2)
########################
resource "aws_security_group" "compute_sg" {
  name   = "${var.asg_name}-sg"
  vpc_id = var.vpc_id

  # SSH ONLY from Bastion SG
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.bastion_sg_id]
  }

  # App traffic from ALB
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, { Name = "${var.asg_name}-sg" })
}

########################
# Launch Template
########################
resource "aws_launch_template" "mysql" {
  name_prefix   = "${var.asg_name}-lt-"
  image_id      = data.aws_ami.ubuntu_22.id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.compute_sg.id]

  user_data = base64encode(var.user_data)

  tags = var.common_tags
}

########################
# Auto Scaling Group
########################
resource "aws_autoscaling_group" "mysql" {
  name              = var.asg_name
  min_size          = 1
  max_size          = 3
  desired_capacity  = 2

  vpc_zone_identifier = var.private_subnets
  target_group_arns  = [var.tg_arn]

  launch_template {
    id      = aws_launch_template.mysql.id
    version = "$Latest"
  }
}

# Data source to fetch current instances in the ASG via instance tags
# ASG sets the tag 'aws:autoscaling:groupName' on instances it manages
data "aws_instances" "asg_instances" {
  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = [aws_autoscaling_group.mysql.name]
  }

  # only include running instances
  instance_state_names = ["running"]
}

