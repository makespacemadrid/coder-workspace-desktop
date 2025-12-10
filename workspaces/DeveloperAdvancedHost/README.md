---
display_name: DeveloperAdvancedHost
description: "DANGER DANGER: acceso Docker host + network host. Usa Developer si no necesitas esto. Autoprovisiona key IA MakeSpace si no rellenas OpenCode."
icon: icon.svg
maintainer_github: makespacemadrid
tags: [docker, workspace, host, danger, makespace]
---

# Developer Advanced Host

**DANGER DANGER**: acceso directo al Docker del host y `network_host`. Úsalo solo si sabes lo que haces.

## Qué incluye
- Escritorio KDE vía KasmVNC, code-server opcional y shell con tooling dev.
- Docker del host (`/var/run/docker.sock`), `network_mode = host`, GPUs si el nodo las expone.
- Apps desktop: VS Code, GitHub Desktop, Claude Desktop, Firefox, Geany, AppImage Pool.
- Stack dev: Docker Engine/Compose, Node.js 20, CLIs de IA (Codex, Claude, Gemini), git/gh, pulseaudio/ALSA.
- Python listo para venvs (`python3-venv`) + venv base en `~/.venvs/base`.
- Accesos directos precreados en el escritorio y módulos KasmVNC, Filebrowser, OpenCode. RDP es solo para workspaces Windows según [la guía de Coder](https://coder.com/docs/user-guides/workspace-access/remote-desktops); esta imagen Linux usa KasmVNC.

## Uso recomendado
- Pruebas que requieran Docker/Network del host, diagnósticos de red, acceso a GPUs del host.
- Si no necesitas tocar el host, usa el template `Developer` (DinD) para más aislamiento.

## Creación rápida en Coder
- Usa esta plantilla solo cuando necesites acceso directo al host.
- `Home`: monta `/home/coder` desde el host (añade UID si la carpeta no es 1000) o deja el volumen Docker por defecto. Puedes nombrarlo o reutilizar uno existente.
- `host-data`: monta una ruta del host en `~/host-data` si necesitas compartir una carpeta concreta.
- `Repositorio Git`: clona en `~/projects` al primer arranque.
- `OpenCode`: si lo dejas vacío, se autoprovisiona una key de IA MakeSpace válida 30 días (`http://iapi.mksmad.org`).

## Parámetros
- `Ruta host para /home (opcional)`: monta `/home/coder` desde una carpeta del host en lugar de un volumen.
- `UID para /home host (opcional)`: UID para ejecutar el contenedor cuando usas la ruta host, evitando problemas de permisos.
- `Nombre volumen /home (opcional)`: nombre del volumen de `/home/coder` si no montas ruta host (por defecto `coder-<workspace-id>-home`).
- `Volumen /home existente (opcional)`: nombre de un volumen ya creado para usarlo como `/home/coder` (no se crea uno nuevo).
- `Ruta host para /home/coder/host-data (opcional)`: monta una carpeta del host dentro del home en `~/host-data`.
- `Repositorio Git (opcional)`: URL para clonar en `~/projects/<nombre-del-repo>` en el primer arranque del workspace.
- `OpenCode provider/API key (opcional)`: configura proveedor OpenAI-compatible al arrancar.

## Notas
- El contenedor lleva labels `com.centurylinklabs.watchtower.*` para que Watchtower pueda actualizarlo si activas `--label-enable`.
- Home persistente en `/home/coder`.
