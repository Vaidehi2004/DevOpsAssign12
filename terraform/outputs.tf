output "controller_public_ip" {
  value = aws_instance.controller.public_ip
}

output "manager_public_ip" {
  value = aws_eip.manager_eip.public_ip
}

output "worker_a_public_ip" {
  value = aws_eip.worker_a_eip.public_ip
}

output "worker_b_public_ip" {
  value = aws_eip.worker_b_eip.public_ip
}

output "private_key_path" {
  value = "${path.module}/terraform-key.pem"
}