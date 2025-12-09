---
display_name: DeveloperBasic
description: "Workspace básico sin escritorio, con code-server y Docker in Docker"
icon: icon.svg
maintainer_github: makespacemadrid
tags: [docker, dind, workspace, makespace]
---

# DeveloperBasic (code-server + DinD)

Workspace ligero basado en la imagen oficial `codercom/enterprise-base:ubuntu`, sin escritorio gráfico. Incluye code-server y Docker in Docker mediante módulos de Coder.

## Cuándo usarlo
- Necesitas un entorno minimalista sin escritorio, solo code-server/terminal.
- Pruebas rápidas con Docker in Docker sin instalar tooling gráfico.

## Qué incluye
- Imagen oficial `codercom/enterprise-base:ubuntu` con tooling base y sudo.
- code-server integrado.
- Docker instalado al iniciar y ejecutando DinD (dockerd dentro del contenedor).
- Home persistente en `/home/coder` y datos de Docker en `/var/lib/docker`.
- Labels `com.centurylinklabs.watchtower.*` para actualizaciones con Watchtower.

## Creación rápida en Coder
- No hay escritorio; usarás code-server o la terminal.
- `Repositorio Git`: clona en `~/projects` al primer arranque.

## Notas
- El contenedor se ejecuta en modo `privileged` para soportar Docker in Docker.
- No hay escritorio gráfico; conéctate vía code-server o la terminal del workspace.
- Tras merge a `main`, ejecuta `coder templates push` para publicar el template en Coder.

### Limitaciones de DinD
- No hay Swarm ni orquestador: `docker compose` ignora la sección `deploy.*`, así que no funcionan `resources.reservations/limits`, `placement`, `replicas`, etc. Usa flags de `docker run`/`docker compose` (`--cpus`, `--memory`, `--gpus`) para limitar contenedores.
- Las reservas de CPU/RAM solo pueden consumir lo que tenga asignado el workspace; los contenedores hijos no pueden reservar más allá de ese presupuesto.
- El Docker interno no accede al Docker del host; si necesitas manejar contenedores del nodo host, usa otro template con acceso al socket.
