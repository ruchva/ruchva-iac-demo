# EJEMPLO MÍNIMO (video 1): Terraform vs Ansible.
#
# Terraform = declarativo: el recurso protagonista es aws_instance.demo.
# Describimos QUÉ queremos que exista (una EC2 con esta AMI, este tamaño,
# esta llave); no escribimos los pasos para crearla. Todo lo demás en este
# archivo (llave, security group, AMI) es el mínimo necesario para que ese
# recurso pueda existir y sea alcanzable por SSH — no es el punto del video.
#
# No genera inventario ni usa Ansible directamente: eso se ve en video 2.
# Aquí, en el video 1, la IP se pasa a mano (ver playbook.yml y el README).

terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "public_key_path" {
  type    = string
  default = "~/.ssh/id_ed25519.pub"
}

variable "allowed_cidr" {
  description = "Restringe esto a tu IP (\"<tu-ip>/32\") antes de grabar."
  type        = string
  default     = "0.0.0.0/0"
}

provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_key_pair" "demo" {
  key_name   = "iac-minimal-demo-key"
  public_key = file(var.public_key_path)
}

resource "aws_security_group" "demo" {
  name        = "iac-minimal-demo-sg"
  description = "Solo SSH, para el ejemplo mínimo del video 1"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# <-- El recurso protagonista del video 1 -->
resource "aws_instance" "demo" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  subnet_id              = data.aws_subnets.default.ids[0]
  key_name               = aws_key_pair.demo.key_name
  vpc_security_group_ids = [aws_security_group.demo.id]

  tags = {
    Name = "iac-minimal-demo"
  }
}

output "public_ip" {
  value = aws_instance.demo.public_ip
}

output "ssh_command" {
  value = "ssh ec2-user@${aws_instance.demo.public_ip}"
}
