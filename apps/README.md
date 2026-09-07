# apps/

Este directorio es un lugar **opcional** para clonar localmente el código
fuente de la aplicación del bootcamp, si en algún momento quieres construir
la imagen tú mismo en lugar de usar la publicada en `ghcr.io`. Todo lo que
pongas aquí (excepto este archivo) está en `.gitignore`: nunca se sube a
este repositorio.

El código que clones aquí **no es tuyo ni de este repositorio**. Pertenece a
la comunidad AWS User Group La Paz (ver `/CREDITS.md`). No modifiques,
renombres ni elimines sus avisos de autoría/licencia si lo clonas.

```bash
git clone https://github.com/AWS-User-Group-La-Paz/muyu-invoice-generator apps/muyu-invoice-generator
```

Para usar el código clonado en vez de la imagen publicada, cambia
`ansible/roles/facturacion/templates/docker-compose.yml.j2`: reemplaza las
líneas `image: ...` de `web` y `worker` por el bloque `build:` que ya está
comentado en ese archivo, apuntando a `apps/muyu-invoice-generator`.
