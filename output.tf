output "vpc_id" {
  value = aws_vpc.main.id
}

output "api_public_ip" {
  value = aws_instance.api_vm.public_ip
}

output "worker1_private_ip" {
  value = aws_instance.worker1.private_ip
}

output "worker2_private_ip" {
  value = aws_instance.worker2.private_ip
}