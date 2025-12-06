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

## Parámetros
- `Habilitar GPUs`: expone GPU si el host la tiene (por defecto ON).
- `Ruta host para /home (opcional)`: monta `/home/coder` desde una carpeta del host en lugar del volumen Docker.
- `UID para /home host (opcional)`: UID para ejecutar el contenedor cuando montas la ruta host, por si la carpeta no es UID 1000.
- `Nombre volumen /home (opcional)`: nombre del volumen de `/home/coder` cuando no montas ruta host (por defecto `coder-<workspace-id>-home`).
- `Volumen /home existente (opcional)`: nombre de un volumen ya creado para reutilizarlo en `/home/coder` (evita crear uno nuevo).
- `Ruta host para /home/coder/host-data (opcional)`: monta una carpeta del host dentro del home en `~/host-data`.
- `Repositorio Git (opcional)`: URL para clonar en `~/projects/<nombre-del-repo>` en el primer arranque del workspace.

## Notas
- Home persistente en volumen Docker (`/home/coder`). Escritorio con accesos directos a las apps clave.
- KasmVNC para escritorio gráfico; incluye code-server y filebrowser si quieres editar assets/scripts.
- Labels `com.centurylinklabs.watchtower.*` para que Watchtower pueda actualizar si usas `--label-enable`.
- Si necesitas más programas (Cura, QCAD, LightBurn, simuladores SPICE), avisa y se añaden a la imagen.

## Publicación
Tras actualizar imagen o template:
1) Merge a `main`.
2) GH Actions publica la imagen en GHCR.
3) `coder templates push` para actualizar el template en Coder.
