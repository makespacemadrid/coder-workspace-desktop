# Imágenes MakeSpace Coder

## coder-mks-developer
- Imagen para desarrollo con escritorio KDE/KasmVNC, Docker, Node.js 20, CLIs de IA (Codex, Claude, Gemini), VS Code, GitHub Desktop, Claude Desktop, AppImage Pool, Geany y audio (PulseAudio/ALSA).
- Build local: `docker build -t coder-mks-developer Docker-Images/Developer`
- GHCR: `ghcr.io/makespacemadrid/coder-mks-developer:latest`

## coder-mks-design
- Imagen para diseño 2D/3D y electrónica (Inkscape, GIMP, Krita, Blender, FreeCAD, OpenSCAD, PrusaSlicer, MeshLab, LibreCAD, KiCad, Fritzing, SimulIDE, LaserGRBL) con AppImage Pool y Geany.
- Build local: `docker build -t coder-mks-design Docker-Images/Designer`
- GHCR: `ghcr.io/makespacemadrid/coder-mks-design:latest`

## Publicación automática
Al hacer push a `main`/`master`, GitHub Actions construye y publica ambas imágenes en GHCR con tags `latest` y `sha`.
