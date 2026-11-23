output "game_host_ip" {
  value = aws_instance.game_host.public_ip
}

output "status_vm_ip" {
  value = aws_instance.status_vm.public_ip
}