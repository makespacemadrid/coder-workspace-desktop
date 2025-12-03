---
display_name: MakeSpace Dev DinD
description: Entorno de desarrollo con Docker in Docker y GPU opcional
icon: ../../../site/static/icon/docker.png
maintainer_github: makespacemadrid
tags: [docker, dind, gpu, workspace, makespace]
---

# MakeSpace Developer DinD

Template pensado para desarrollar con **Docker in Docker (DinD)** sin tocar el Docker del host. Usa la misma imagen `ghcr.io/makespacemadrid/coder-mks-developer:latest`, escritorio XFCE/KasmVNC y herramientas dev + IA.

## Qué incluye
- Docker Engine y docker-compose-plugin dentro del contenedor (modo DinD).
- Navegador Firefox (.deb), code-server, Cursor, JupyterLab, Tmux, Filebrowser.
- Node.js 20 y CLIs de IA (OpenAI/Codex, Claude, Gemini).
- Volumen persistente para `/home/coder` y para `/var/lib/docker` (tus contenedores DinD sobreviven reinicios).
- Exposición opcional de puertos al host.
- GPUs opcionales (checkbox al crear el workspace).

## Parámetros en Coder
- `Expose ports`: habilita o no el mapeo de puertos al host.
- `port_range_start` / `port_range_end`: rango a exponer si activas el mapeo.
- `Habilitar GPUs`: activa `--gpus all` en el contenedor. Úsalo solo si el nodo tiene GPU configurada.

## Notas de uso
- El daemon Docker se arranca dentro del contenedor en el startup script (`dockerd` con overlay2). No usa el socket del host.
- Los contenedores e imágenes DinD se guardan en el volumen `/var/lib/docker`; se limpian si borras el workspace.
- Para acceso gráfico, abre la consola del workspace y entra a KasmVNC (XFCE).
- Si necesitas más tooling de sistema, añade en la imagen base o en el startup script.

## Cómo publicar cambios
- Edita este template y la imagen base en `Docker-Images/Developer/Dockerfile`.
- Ejecuta `coder templates push` después de mergear a `main` para desplegar los cambios en Coder.
