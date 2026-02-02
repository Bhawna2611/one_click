output "private_instance_ips" {
  description = "Private IPs from compute autoscaling group (list)"
  value       = module.compute.private_ips
}

output "bastion_public_ip" {
  value = module.bastion.bastion_public_ip
}

