---
display_name: MakeSpace Dev Workspace
description: Workspace de desarrollo con Docker del host y GPU (KasmVNC + code-server)
icon: icon.svg
maintainer_github: makespacemadrid
tags: [docker, workspace, makespace]
---

# MakeSpace Developer avanzado

Workspace de desarrollo con:
- Escritorio XFCE por KasmVNC, code-server y Cursor.
- Docker del host montado (`/var/run/docker.sock`) y GPUs si el nodo las expone.
- Node.js 20 + CLIs de IA (Codex, Claude, Gemini), git, Docker Compose, etc.
- Home persistente (`/home/coder`), puertos al host opcionales.

Uso típico:
- Dev general, backend, DevOps, automatización con Docker Compose.
- Testing con GPU o builds que necesiten Docker del host.

Notas:
- El socket Docker del host es sensible: úsalo con cuidado.
- Si no necesitas tocar el Docker del host, usa el template DinD.
