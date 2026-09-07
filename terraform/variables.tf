variable "aws_region" {
  description = "Región de AWS donde se crea la infraestructura."
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Tamaño de la instancia EC2 que corre Postgres, LocalStack, Mailpit, web y worker."
  type        = string
  default     = "t3.small"
}

variable "allowed_cidr" {
  description = "CIDR permitido para SSH, la app y la UI de Mailpit. Restríngelo a tu IP (\"<tu-ip>/32\") antes de grabar; el default 0.0.0.0/0 es solo para que el ejemplo funcione sin configuración previa."
  type        = string
  default     = "0.0.0.0/0"
}

variable "public_key_path" {
  description = "Ruta local a tu clave pública SSH."
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "project_name" {
  description = "Prefijo para nombres y tags de los recursos."
  type        = string
  default     = "muyu-iac-bootcamp"
}

variable "ssh_user" {
  description = "Usuario SSH de la AMI (ec2-user en Amazon Linux 2023). Se escribe en el inventario de Ansible."
  type        = string
  default     = "ec2-user"
}

variable "app_port" {
  description = "Puerto donde escucha el proceso web de Muyu (variable PORT dentro del contenedor). No es 80 porque el proceso corre como usuario sin privilegios."
  type        = number
  default     = 3000
}

variable "mailpit_ui_port" {
  description = "Puerto de la UI web de Mailpit, para ver en el navegador los correos que envía el worker."
  type        = number
  default     = 8025
}
