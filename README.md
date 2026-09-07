# muyu-iac-bootcamp

Repositorio de Infraestructura como Código para tres videos didácticos sobre
**Terraform y Ansible**: (1) la diferencia entre ambos, (2) los dos
trabajando juntos para desplegar un sistema real, (3) destruir esa
infraestructura con un comando.

> **Las aplicaciones que este repositorio despliega (web + worker del
> sistema de facturación "Muyu") son de la comunidad AWS User Group La Paz,
> no de este autor.** Este repositorio solo aporta la infraestructura y el
> despliegue (Terraform + Ansible). Ver [`CREDITS.md`](./CREDITS.md) para la
> atribución completa.

## Qué es mío / qué es de la comunidad

| | Autoría |
|---|---|
| `terraform/`, `ansible/`, `examples/` — toda la IaC de este repo | Este autor |
| El sistema de facturación desplegado (`muyu-invoice-generator`: proceso web + worker) | Comunidad AWS User Group La Paz — [repositorio](https://github.com/AWS-User-Group-La-Paz/muyu-invoice-generator) |
| El despliegue productivo real del bootcamp (ECS + RDS + ALB) | Comunidad AWS User Group La Paz — [repositorio](https://github.com/AWS-User-Group-La-Paz/muyu-invoice-infrastructure), no vive en este repo |

## Nota sobre la arquitectura real de la app

La app del bootcamp **no** tiene un frontend separado ni usa Redis: es un
único proceso Node/Express (imagen `muyu-invoice-generator`) que corre como
**web** (`node src/web.js`) o como **worker** (`node src/worker.js`), más
PostgreSQL. En producción usa AWS SQS + S3 + SES; en cualquier otro
`NODE_ENV` usa LocalStack (SQS), disco local y Mailpit — igual que el
`docker-compose.yml` del propio proyecto para desarrollo local.

Para el video 2, este repo reproduce ese modo "no producción" (LocalStack +
Mailpit) dentro de un único EC2, en vez de aprovisionar SQS/S3/SES reales.
Es la opción más rápida de grabar y destruir, y no requiere verificar un
remitente en SES antes de que la demo funcione. La alternativa "productiva"
(SQS/S3/SES reales + IAM) queda fuera de alcance de este repo — para eso ya
existe `muyu-invoice-infrastructure`.

## Los tres videos

| Video | Idea | Qué se muestra | Dónde |
|---|---|---|---|
| 1 | Terraform vs Ansible (declarativo vs imperativo) | Un `terraform apply` que crea un solo recurso, y una tarea de Ansible que lo configura | `examples/minimal/` |
| 2 | Juntos: Terraform crea el servidor y entrega su IP; Ansible despliega el sistema de facturación | El handoff (IP → inventario → `ansible-playbook`) y la app respondiendo en el navegador | `terraform/` + `ansible/` |
| 3 | `terraform destroy` | El plan de destrucción y el conteo bajando a cero | `terraform/` |

## Requisitos previos

- Cuenta AWS con credenciales configuradas (región por defecto `us-east-1`).
- Terraform >= 1.6 y Ansible >= 2.15.
- Un par de claves SSH (`public_key_path`, por defecto `~/.ssh/id_ed25519.pub`).

## Estructura

```
muyu-iac-bootcamp/
├── README.md
├── CREDITS.md
├── terraform/           # EC2 + SG + EIP, escribe ansible/inventory.ini
├── ansible/             # Configura el host y despliega el stack
├── apps/                # Opcional: clonar el código fuente para build local
└── examples/minimal/    # Para el video 1
```

## Uso por video

### Video 1 — concepto

```bash
cd examples/minimal
terraform init && terraform apply     # declarativo: "qué quiero"
ansible-playbook -i "$(terraform output -raw public_ip)," -u ec2-user playbook.yml   # imperativo: "los pasos"
ssh ec2-user@"$(terraform output -raw public_ip)" cat hello-ansible.txt              # mostrar el resultado
terraform destroy                     # limpiar el ejemplo
```

### Video 2 — juntos, stack real

```bash
cd terraform
terraform init
terraform apply -var="allowed_cidr=<tu-ip>/32"    # crea EC2 + EIP y escribe ansible/inventory.ini

cd ../ansible
ansible-playbook playbook.yml \
  --extra-vars "postgres_password=<una-contraseña>"   # instala Docker y levanta el stack

# abrir la app_url del output de terraform en el navegador
# abrir mailpit_url para ver el correo que envía el worker al terminar
```

Restringe `allowed_cidr` a tu propia IP antes de grabar; el default
`0.0.0.0/0` solo existe para que el repo funcione sin configuración previa.

### Video 3 — destroy

```bash
cd terraform
terraform destroy
terraform state list   # debe quedar vacío
```

## Apuntar a las imágenes reales de la comunidad

Por defecto, `ansible/group_vars/all.yml` usa
`ghcr.io/aws-user-group-la-paz/muyu-invoice-generator:latest` para web y
worker (es la misma imagen; solo cambia el comando). Para fijar una versión
concreta, cambia `app_image_tag` en ese archivo o pásalo por `--extra-vars`.

Para construir desde el código fuente en lugar de usar la imagen publicada:

1. Clona el repo de la app en `apps/` (ver `apps/README.md`).
2. En `ansible/roles/facturacion/templates/docker-compose.yml.j2`, en los
   servicios `web` y `worker`, comenta la línea `image:` y descomenta la
   línea `build:` que ya está en el archivo.

## Costos y teardown

- Un único `t3.small` corre los cinco contenedores (Postgres, LocalStack,
  Mailpit, web, worker) para la demo.
- El volumen de Postgres es un volumen Docker en el disco de la instancia:
  desaparece con la instancia, no requiere limpieza aparte.
- La EIP se libera en `terraform destroy`.
- Verificación: después de `terraform destroy`, `terraform state list` debe
  quedar vacío y no debe haber recursos facturables en la cuenta.

## Fuera de alcance

Estado remoto de Terraform, balanceador/autoescalado/RDS gestionado, CI/CD,
y cualquier mejora al código de las aplicaciones de la comunidad. Todo se
ejecuta manualmente desde la máquina de quien graba.
