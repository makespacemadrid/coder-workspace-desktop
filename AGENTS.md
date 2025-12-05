# Plantillas de workspaces Coder

> Nota: puedes añadir un `AGENTS.private.md` (no versionado) con indicaciones privadas o específicas del entorno.

## Imágenes
- `ghcr.io/makespacemadrid/coder-mks-developer:latest` (build desde `Docker-Images/Developer/Dockerfile`). Incluye escritorio KDE/KasmVNC, Docker Engine, Node.js 20, CLIs de IA (Codex, Claude, Gemini), VS Code, GitHub Desktop, Claude Desktop, AppImage Pool, audio (PulseAudio/ALSA), Geany y tooling dev (Docker, gh, etc.).
- `ghcr.io/makespacemadrid/coder-mks-design:latest` (build desde `Docker-Images/Designer/Dockerfile`). Enfoque en diseño 2D/3D y electrónica: Inkscape, GIMP, Krita, Blender, FreeCAD, OpenSCAD, PrusaSlicer, OrcaSlicer, MeshLab, LibreCAD, KiCad, Fritzing, SimulIDE, LaserGRBL (Wine), AppImage Pool, Geany.

## Templates
- `DeveloperAdvancedHost`: **DANGER DANGER, este workspace tiene acceso docker host y network host, usar con cuidado. Si no sabes lo que haces el template Developer es el que buscas.** Misma imagen developer, home persistente. Incluye VS Code, GitHub Desktop, Claude Desktop, AppImage Pool, RDP opcional.
- `Developer`: Workspace de desarrollo general con Docker-in-Docker, volúmenes persistentes (`/home/coder`, `/var/lib/docker`), GPUs opcionales, red bridge. Misma imagen developer.
- `Designer`: escritorio KDE/KasmVNC con herramientas de diseño; GPUs opcionales; home persistente; AppImage Pool y módulos Filebrowser/OpenCode/RDP.

Todos los contenedores llevan labels `com.centurylinklabs.watchtower.*` para que Watchtower pueda actualizarlos si se despliega con `--label-enable` + `--scope coder-workspaces`.

## Publicación
Tras modificar imagen o templates:
1) Merge en `main`.
2) GH Actions (`.github/workflows/build.yml`) construye y publica la imagen en GHCR con tag `latest` y `sha`.
3) Ejecuta `coder templates push` desde el repo para actualizar los templates en Coder (solo aplica a nuevos workspaces).

## Watchtower
- Las imágenes y contenedores vienen etiquetados para `watchtower` (`--label-enable`, scope `coder-workspaces`).
- Ejemplo de despliegue en `watchtower/docker-compose.yml` (busca updates cada 6h e incluye un servicio de muestra).

## Instrucciones locales / sensibles
- No incluyas endpoints, hosts ni credenciales en este archivo. Usa `AGENTS.private.md` (gitignore) para instrucciones locales o con datos sensibles del entorno/producción.
- Mantén `AGENTS.private.md` actualizado con cualquier flujo de actualización manual o accesos específicos de un host.
