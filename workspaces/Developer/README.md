---
display_name: Developer
description: "Workspace de desarrollo general con Docker in Docker y GPU opcional (autoprovisiona key MakeSpace de IA si no rellenas OpenCode)"
icon: icon.svg
maintainer_github: makespacemadrid
tags: [docker, dind, gpu, workspace, makespace]
---

# Developer (Docker in Docker)

Workspace de desarrollo general con **Docker in Docker (DinD)** y escritorio KDE/KasmVNC. Usa la imagen `ghcr.io/makespacemadrid/coder-mks-developer:latest`.

## Para qué sirve
- Entornos de desarrollo aislados sin tocar el Docker del host.
- Proyectos que necesitan GPU opcional y mapeo de puertos a host.
- Sesiones gráficas ligeras (KasmVNC) con herramientas dev y CLIs de IA.

## Qué incluye
- Docker Engine y docker-compose-plugin internos (DinD, no se usa el socket del host).
- Escritorio KDE/KasmVNC, code-server y Filebrowser. RDP solo aplica a workspaces Windows según [la guía de Coder](https://coder.com/docs/user-guides/workspace-access/remote-desktops).
- Apps desktop: VS Code, GitHub Desktop, Claude Desktop, Firefox, Geany, AppImage Pool.
- Node.js 20, CLIs de IA (OpenAI/Codex, Claude, Gemini), git/gh y audio (PulseAudio/ALSA).
- Python con `python3-venv` y venv base en `~/.venvs/base`.
- Volúmenes persistentes: `/home/coder` y `/var/lib/docker`.

## Creación rápida en Coder
- Activa `Habilitar GPUs` solo si el nodo tiene GPU.
- `Exponer puertos al host` + `port_range_start`/`port_range_end` para publicar servicios.
- `Home`:
  - Ruta host opcional para `/home/coder` + UID si la carpeta no es 1000.
  - Si no usas ruta host, puedes nombrar el volumen o reutilizar uno existente.
  - `Ruta host para ~/host-data` monta una carpeta puntual del host dentro del home.
- `Docker data`: nombra o reutiliza el volumen de `/var/lib/docker` si quieres compartirlo.
- `Repositorio Git` clona en `~/projects` al primer arranque.
- `OpenCode` (URL/API key): si lo dejas vacío, se autoprovisiona una key de IA MakeSpace válida 30 días (`http://iapi.mksmad.org`).

## Notas de uso
- El daemon Docker se arranca dentro del contenedor (`dockerd` con overlay2) y guarda datos en `/var/lib/docker`.
- Usa KasmVNC para escritorio KDE (consola del workspace -> abrir URL de KasmVNC).
- El contenedor lleva labels `com.centurylinklabs.watchtower.*` para auto-actualización vía Watchtower.

### Limitaciones de DinD
- No hay Swarm ni orquestador, por lo que `docker compose` ignora la sección `deploy.*` (incluidos `resources.reservations/limits`, `placement`, `replicas`); solo aplican los flags directos de `docker run`/`docker compose` como `--cpus` o `--memory`.
- Las reservas de recursos son contra el propio workspace: los contenedores hijos comparten el presupuesto de CPU/RAM que tenga asignado el workspace y no pueden reservar más que eso.
- El Docker interno no ve el Docker del host; si necesitas gestionar contenedores/volúmenes del nodo, usa el template DeveloperAdvancedHost.

## Cómo publicar cambios
- Edita este template y la imagen base en `Docker-Images/Developer/Dockerfile`.
- Tras el merge a `main`, ejecuta `coder templates push` para desplegar el template en Coder.
