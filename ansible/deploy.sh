#!/bin/bash
set -e

echo "=== Extracting Terraform Outputs ==="
BASTION_IP=$(terraform output -raw bastion_public_ip)
PRIVATE_IP=$(terraform output -raw private_instance_ip)

echo "Bastion IP: $BASTION_IP"
echo "Private Instance IP: $PRIVATE_IP"

echo ""
echo "=== Updating Ansible Inventory ==="
cp inventory.ini inventory.ini.bak
sed -i "s/BASTION_IP_PLACEHOLDER/$BASTION_IP/g" inventory.ini
sed -i "s/PRIVATE_IP_PLACEHOLDER/$PRIVATE_IP/g" inventory.ini

echo "Inventory updated successfully"

echo ""
echo "=== Testing SSH Connection to Bastion ==="
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 ubuntu@$BASTION_IP "echo 'Bastion connection successful'"

echo ""
echo "=== Testing SSH Connection to Private Instance via Bastion ==="
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 -o ProxyCommand="ssh -W %h:%p -q ubuntu@$BASTION_IP" ubuntu@$PRIVATE_IP "echo 'Private instance connection successful'"

echo ""
echo "=== Running Ansible Playbook ==="
ansible-playbook -i inventory.ini playbook.yml -v

echo ""
echo "=== Deployment Completed Successfully ==="
