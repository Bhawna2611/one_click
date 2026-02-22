output "private_instance_ips" {
  description = "Private IPs from compute autoscaling group (list)"
  value       = module.compute.private_ips
}

output "private_instance_ip" {
  description = "Primary private IP (first instance) - convenience for scripts that expect single IP"
  value       = module.compute.private_ip
}

output "bastion_public_ip" {
  value = module.bastion.bastion_public_ip
}

output "alb_dns" {
  description = "DNS name of the application load balancer"
  value       = module.alb.alb_dns
}

