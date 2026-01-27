output "private_ip" {
  value = aws_instance.private_ubuntu.private_ip
}
output "public_ip" {
  value = aws_instance.public_ubuntu.public_ip
}