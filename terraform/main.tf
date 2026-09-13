# Red y AMI por data source: usamos la VPC y subredes default de la cuenta
# y resolvemos la AMI de Amazon Linux 2023 más reciente, para no hardcodear
# IDs que cambian por región y con el tiempo. Esto también deja un teardown
# limpio: no creamos VPC ni subredes que "destroy" tenga que desenredar.

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

resource "aws_key_pair" "this" {
  key_name   = "${var.project_name}-key"
  public_key = file(pathexpand(var.public_key_path))
}

resource "aws_security_group" "this" {
  name        = "${var.project_name}-sg"
  description = "SSH, app web y UI de Mailpit para la demo de Terraform + Ansible"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    description = "App web del sistema de facturacion (Muyu)"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    description = "UI de Mailpit (correos de prueba enviados por el worker)"
    from_port   = var.mailpit_ui_port
    to_port     = var.mailpit_ui_port
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = var.project_name
  }
}

resource "aws_instance" "this" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnets.default.ids[0]
  key_name               = aws_key_pair.this.key_name
  vpc_security_group_ids = [aws_security_group.this.id]

  tags = {
    Name    = "${var.project_name}-host"
    Project = var.project_name
  }
}

resource "aws_eip" "this" {
  instance = aws_instance.this.id
  domain   = "vpc"

  tags = {
    Name    = "${var.project_name}-eip"
    Project = var.project_name
  }
}

# El handoff del video 2: Terraform entrega la IP escribiendo el inventario
# que Ansible va a leer. No hay paso manual entre "apply" y "playbook".
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory.ini"
  content = templatefile("${path.module}/inventory.tftpl", {
    public_ip = aws_eip.this.public_ip
    ssh_user  = var.ssh_user
  })
}
