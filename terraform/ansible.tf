resource "local_file" "ansible_inventory" {
  content  = <<EOT
[web]
web_server ansible_host=${module.compute.private_ip} ansible_user=ubuntu

[web:vars]
ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q ubuntu@${module.compute.public_ip}"'
EOT
  filename = "../ansible/inventory.ini"
}
