output "public_ip" {
  description = "IP pública (Elastic IP) de la instancia."
  value       = aws_eip.this.public_ip
}

output "app_url" {
  description = "URL del sistema de facturación, una vez desplegado con Ansible."
  value       = "http://${aws_eip.this.public_ip}:${var.app_port}"
}

output "mailpit_url" {
  description = "URL de la UI de Mailpit, para ver los correos que envía el worker."
  value       = "http://${aws_eip.this.public_ip}:${var.mailpit_ui_port}"
}

output "ssh_command" {
  description = "Comando para entrar por SSH a la instancia."
  value       = "ssh ${var.ssh_user}@${aws_eip.this.public_ip}"
}

output "ansible_command" {
  description = "Comando exacto a correr después de terraform apply para desplegar el stack."
  value       = "cd ../ansible && ansible-playbook playbook.yml --extra-vars \"postgres_password=<tu-password>\""
}
