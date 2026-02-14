resource "local_file" "ansible_inventory" {
  content  = <<EOT
[web]
web_server ansible_host=${module.compute.private_ip} ansible_user=${var.ansible_user}

[web:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -i ${var.ssh_key_path} -W %h:%p -q -o StrictHostKeyChecking=no ubuntu@${module.bastion.bastion_public_ip}"'
ansible_python_interpreter=/usr/bin/python3
EOT
  filename = var.inventory_file
  directory_permission = "0777"
  file_permission      = "0777"
}
