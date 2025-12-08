---
display_name: MakeSpace Designer
description: Entorno gráfico para diseño 2D/3D y electrónica
icon: icon.svg
maintainer_github: makespacemadrid
tags: [design, cad, 3d, electronics, makespace]
---

# MakeSpace Designer

Template con escritorio KDE/KasmVNC y herramientas de diseño 2D/3D + electrónica usando la imagen `ghcr.io/makespacemadrid/coder-mks-design:latest`.

## Apps incluidas (imagen base)
- 2D: Inkscape, GIMP, Krita
- 3D/CAD: Blender, FreeCAD, OpenSCAD, MeshLab, LibreCAD
- Impresión 3D: PrusaSlicer, OrcaSlicer (AppImage)
- Electrónica/EDA: KiCad (footprints/símbolos/templates), Fritzing, SimulIDE
- Láser/CNC: LaserGRBL (via Wine)
- Navegación y utilidades: Firefox (.deb, sin snap), Geany, AppImage Pool (tienda/gestor de AppImage)
- Módulos Coder: KasmVNC, Filebrowser, OpenCode. RDP aplica solo a workspaces Windows según [las docs de Coder](https://coder.com/docs/user-guides/workspace-access/remote-desktops); esta imagen Linux usa KasmVNC.

## Creación rápida en Coder
- `Habilitar GPUs`: déjalo activo solo si el nodo tiene GPU configurada.
- `Home`: usa volumen Docker por defecto o monta `/home/coder` desde el host (añade UID si no es 1000). Puedes reutilizar o nombrar el volumen.
- `host-data`: monta una ruta concreta del host en `~/host-data` si necesitas intercambiar archivos puntuales.
- `Repositorio Git`: clona en `~/projects` al primer arranque.
- `OpenCode`: añade URL/API key solo si quieres un proveedor OpenAI-compatible preconfigurado.

## Notas
- Home persistente en volumen Docker (`/home/coder`). Escritorio con accesos directos a las apps clave.
- KasmVNC para escritorio gráfico; incluye code-server y filebrowser por si necesitas editar assets/scripts.
- Labels `com.centurylinklabs.watchtower.*` para que Watchtower pueda actualizar si usas `--label-enable`.
- Si necesitas más programas (Cura, QCAD, LightBurn, simuladores SPICE), avisa y se añaden a la imagen.

## Publicación
Tras actualizar imagen o template:
1) Merge a `main`.
2) GH Actions publica la imagen en GHCR.
3) `coder templates push` para actualizar el template en Coder.
