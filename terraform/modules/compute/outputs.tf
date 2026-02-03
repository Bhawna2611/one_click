output "compute_sg_id" {
  value = aws_security_group.compute_sg.id
}

output "instance_ids" {
  description = "List of instance IDs currently in the compute ASG"
  value       = data.aws_instances.asg_instances.ids
}

output "private_ips" {
  description = "List of private IPs for instances currently in the compute ASG"
  value       = data.aws_instances.asg_instances.private_ips
}

output "public_ip" {
  value = aws_instance.your_instance_name.public_ip
}

output "private_ip" {
  value = aws_instance.your_instance_name.private_ip
}