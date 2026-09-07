# Créditos

Las aplicaciones que este repositorio despliega (el sistema de facturación
**Muyu**: proceso web + worker) **no son de este autor**. Pertenecen a la
comunidad **AWS User Group La Paz** y a quienes construyeron el proyecto
para su bootcamp. Este repositorio ("muyu-iac-bootcamp") solo aporta la
infraestructura y el despliegue (Terraform + Ansible) usados en los videos
didácticos; el código de las aplicaciones no se modifica, ni se renombra,
ni se reescribe aquí.

## Aplicación desplegada

- **muyu-invoice-generator** — servidor Node/Express que genera facturas en
  PDF de forma asíncrona (web + worker sobre la misma imagen).
  Repositorio: <https://github.com/AWS-User-Group-La-Paz/muyu-invoice-generator>
  Autoría: Yamil Urbina.

## Infraestructura original de referencia (no es este repositorio)

El bootcamp despliega esta misma aplicación en un stack productivo real
(ECS Fargate + RDS + ALB + Route 53 + observabilidad) en:

- **muyu-invoice-infrastructure**
  Repositorio: <https://github.com/AWS-User-Group-La-Paz/muyu-invoice-infrastructure>
  Autoría: Yamil Urbina, Sergio Guillen.

El Terraform + Ansible de **este** repositorio (`terraform/`, `ansible/`) es
una versión deliberadamente simplificada — un solo EC2 con Docker Compose,
pensada para grabarse en un video corto — y no sustituye ni representa el
despliegue real del bootcamp.

## Comunidad

- **AWS User Group La Paz** — <https://github.com/AWS-User-Group-La-Paz>
- TODO: agrega aquí el enlace al meetup / redes sociales / sitio web de la
  comunidad, si quieres darles más visibilidad en la descripción del video.
- TODO: si quieres nombrar a más colaboradores específicos del bootcamp,
  agrégalos aquí (nombre + enlace a su perfil).

## Nota sobre licencias

Al momento de escribir esto, ninguno de los dos repositorios de origen
incluye un archivo `LICENSE`. No asumas que su código es de uso libre: si
piensas reutilizar o redistribuir algo más allá de correr la imagen publicada
en `ghcr.io/aws-user-group-la-paz/muyu-invoice-generator`, contacta antes a
sus autores.
