
resource "aws_security_group" "bastion_sg" {
  name   = "bastion-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, { Name = "bastion-sg" })
}

resource "aws_instance" "bastion" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.public_subnet_id
  key_name      = var.key_name

  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true

  
  tags = merge(var.common_tags, {
    Name = "bastion-host"
  })
}

resource "null_resource" "copy_key" {
  triggers = {
    bastion_id = aws_instance.bastion.id
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.ssh_key_path)
    host        = aws_instance.bastion.public_ip
  }

  provisioner "file" {
    source      = var.ssh_key_path
    destination = "/home/ubuntu/one__click.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/ubuntu/one__click.pem"
    ]
  }
}
