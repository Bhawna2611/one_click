data "aws_ami" "ubuntu_22" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_security_group" "ssh_access" {
  name   = "allow_ssh_docker"
  vpc_id = var.vpc_id

  # SSH Access (Port 22) - Required for Ansible
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # MySQL Access (Port 3306) - Required for Docker MySQL
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Internal Traffic - Essential for Bastion to Private communication
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "ssh-docker-sg"
  })
}

resource "aws_instance" "public_ubuntu" {
  ami                    = data.aws_ami.ubuntu_22.id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.ssh_access.id]
  
  # IMPORTANT: Change 'one_click' to the exact name of your key in AWS Console
  key_name               = "one_click" 

  tags = merge(var.common_tags, {
    Name = var.public_instance_name
  })
}

resource "aws_instance" "private_ubuntu" {
  ami                    = data.aws_ami.ubuntu_22.id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [aws_security_group.ssh_access.id]
  
  # IMPORTANT: Use the same key here
  key_name               = "one_click"

  tags = merge(var.common_tags, {
    Name = var.private_instance_name
  })
}