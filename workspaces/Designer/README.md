---
display_name: MakeSpace Designer
description: Entorno gráfico para diseño 2D/3D y electrónica
icon: ../../assets/icons/design.svg
maintainer_github: makespacemadrid
tags: [design, cad, 3d, electronics, makespace]
---

# MakeSpace Designer

Template con escritorio XFCE/KasmVNC y herramientas de diseño 2D/3D + electrónica usando la imagen `ghcr.io/makespacemadrid/coder-mks-design:latest`.

## Apps incluidas (imagen base)
- Inkscape, GIMP, Krita (2D)
- Blender, FreeCAD, OpenSCAD, MeshLab, LibreCAD (3D/CAD)
- PrusaSlicer y OrcaSlicer (impresión 3D)
- KiCad (EDA, con footprints/símbolos/templates), Fritzing, SimulIDE
- LaserGRBL (vía Wine)
- Firefox (.deb, sin snap)

## Parámetros
- `Habilitar GPUs`: expone `--gpus all` si el host tiene GPU configurada (por defecto ON).

## Notas
- Home persistente en volumen Docker (`/home/coder`).
- KasmVNC para escritorio gráfico; incluye code-server y filebrowser si quieres editar assets/scripts.
- Si necesitas más programas (Cura, OrcaSlicer, QCAD, LightBurn, simuladores SPICE), avisa y se añaden a la imagen.

## Publicación
Tras actualizar imagen o template:
1) Merge a `main`.
2) GH Actions publica la imagen en GHCR.
3) `coder templates push` para actualizar el template en Coder.
