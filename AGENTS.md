# Plantillas de workspaces Coder

## Imágenes
- `ghcr.io/makespacemadrid/coder-mks-developer:latest` (build desde `Docker-Images/Developer/Dockerfile`). Incluye escritorio XFCE/KasmVNC, Docker Engine, Node.js 20, CLIs de IA (Codex, Claude, Gemini) y tooling dev.

## Templates
- `DeveloperAdvanced`: acceso directo al Docker del host (monta `/var/run/docker.sock`), GPUs habilitadas por defecto, puertos opcionales, home persistente.
- `DeveloperDIND`: Docker-in-Docker con daemon propio y volumen persistente para `/var/lib/docker`; GPUs opcionales al crear el workspace; misma imagen base que `DeveloperAdvanced`.

## Publicación
Tras modificar imagen o templates:
1) Merge en `main`.
2) GH Actions (`.github/workflows/build.yml`) construye y publica la imagen en GHCR con tag `latest` y `sha`.
3) Ejecuta `coder templates push` desde el repo para actualizar los templates en Coder (solo aplica a nuevos workspaces).
