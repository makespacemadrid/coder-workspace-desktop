---
display_name: Developer
description: "Workspace de desarrollo general con Docker in Docker y GPU opcional"
icon: icon.svg
maintainer_github: makespacemadrid
tags: [docker, dind, gpu, workspace, makespace]
---

# Developer (Docker in Docker)

Template pensado para desarrollar con **Docker in Docker (DinD)** sin tocar el Docker del host. Usa la imagen `ghcr.io/makespacemadrid/coder-mks-developer:latest`, escritorio KDE/KasmVNC y herramientas dev + IA.

## Qué incluye
- Docker Engine y docker-compose-plugin dentro del contenedor (DinD, no usa el socket del host).
- Escritorio KDE/KasmVNC, code-server y Filebrowser. RDP solo aplica a workspaces Windows (según [docs de Coder](https://coder.com/docs/user-guides/workspace-access/remote-desktops)); esta imagen Linux usa KasmVNC para escritorio.
- Apps desktop: VS Code, GitHub Desktop, Claude Desktop, Firefox, Geany, AppImage Pool.
- Node.js 20 y CLIs de IA (OpenAI/Codex, Claude, Gemini); git/gh, pulseaudio/ALSA para audio.
- Python con `python3-venv` y venv base en `~/.venvs/base` para usar al arrancar.
- Volúmenes persistentes: `/home/coder` y `/var/lib/docker` (contenedores DinD persisten entre arranques).
- Puertos al host opcionales; GPUs opcionales (si el nodo tiene GPU).

## Parámetros en Coder
- `Expose ports`: habilita o no el mapeo de puertos al host.
- `port_range_start` / `port_range_end`: rango a exponer si activas el mapeo.
- `Habilitar GPUs`: activa `--gpus all` en el contenedor. Úsalo solo si el nodo tiene GPU configurada.

## Notas de uso
- El daemon Docker se arranca dentro del contenedor en el startup script (`dockerd` con overlay2). No usa el socket del host.
- Los contenedores e imágenes DinD se guardan en el volumen `/var/lib/docker`; se limpian si borras el workspace.
- Para acceso gráfico, abre la consola del workspace y entra a KasmVNC (XFCE).
- Si necesitas más tooling de sistema, añade en la imagen base o en el startup script.
- El contenedor lleva labels `com.centurylinklabs.watchtower.*` para que Watchtower pueda actualizarlo si activas `--label-enable`.

## Cómo publicar cambios
- Edita este template y la imagen base en `Docker-Images/Developer/Dockerfile`.
- Ejecuta `coder templates push` después de mergear a `main` para desplegar los cambios en Coder.
