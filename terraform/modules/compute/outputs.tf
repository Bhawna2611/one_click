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

# Return a single private IP (first running instance) or an empty string when none present.
# Guarded to avoid errors when ASG hasn't launched instances yet.
output "private_ip" {
  description = "Primary private IP (first instance in ASG) or empty if none"
  value       = length(data.aws_instances.asg_instances.private_ips) > 0 ? data.aws_instances.asg_instances.private_ips[0] : ""
}