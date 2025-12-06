---
display_name: DeveloperBasic
description: "Workspace básico sin escritorio, con code-server y Docker in Docker"
icon: icon.svg
maintainer_github: makespacemadrid
tags: [docker, dind, workspace, makespace]
---

# DeveloperBasic (code-server + DinD)

Workspace ligero basado en la imagen oficial `codercom/enterprise-base:ubuntu`, sin escritorio gráfico. Incluye code-server y Docker in Docker mediante módulos de Coder.

## Qué incluye
- Imagen oficial `codercom/enterprise-base:ubuntu` con tooling base y sudo.
- Módulos Coder para `code-server` y `docker-in-docker`.
- Home persistente en `/home/coder` y datos de Docker en `/var/lib/docker`.
- Labels `com.centurylinklabs.watchtower.*` para actualizaciones con Watchtower.

## Parámetros
- `Repositorio Git (opcional)`: URL para clonar en `~/projects/<nombre-del-repo>` en el primer arranque del workspace.

## Notas
- El contenedor se ejecuta en modo `privileged` para soportar Docker in Docker.
- No hay escritorio gráfico; conéctate vía code-server o la terminal del workspace.
- Tras merge a `main`, ejecuta `coder templates push` para publicar el template en Coder.
