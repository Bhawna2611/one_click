output "private_instance_ip" {
  value = module.compute.private_ip
}

output "bastion_public_ip" {
  value = module.compute.public_ip
}