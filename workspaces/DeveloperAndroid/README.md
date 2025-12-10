---
display_name: Developer Android
description: "Workspace KDE con toolchain Android (SDK/CLI), Node 20 y VS Code"
icon: icon.svg
maintainer_github: makespacemadrid
tags: [android, mobile, kde, workspace, makespace]
---

# Developer Android

Workspace gráfico KDE/KasmVNC con toolchain Android preinstalado. Usa la imagen `ghcr.io/makespacemadrid/coder-mks-developer-android:latest`.

## Qué incluye
- Android SDK CLI con `platform-tools`, `build-tools 34.0.0`, `platforms;android-34`, emulator y `cmdline-tools;latest`.
- Java 17, Node.js 20 (npm/pnpm/yarn), git/git-lfs y utilidades de desarrollo.
- VS Code con extensiones de IA y soporte C/C++ preinstalado.
- Módulos Coder: KasmVNC (KDE), code-server, Filebrowser, OpenCode, git-config, tmux.
- Autoprovisiona una key de IA MakeSpace (30 días) si dejas vacío OpenCode (URL/API key); usa `http://iapi.mksmad.org`.

## Creación rápida en Coder
- `GPU`: solo si el nodo tiene GPU configurada.
- `Home`: usa volumen Docker por defecto o monta `/home/coder` desde el host (añade UID si no es 1000). Puedes reutilizar o nombrar el volumen.
- `host-data`: monta una ruta concreta del host en `~/host-data` si necesitas compartir archivos.
- `Repositorio Git`: clona en `~/projects` al primer arranque.
- `OpenCode`: deja vacío para autoprovisionar la key MakeSpace de 30 días.

## Notas
- Escritorio KDE vía KasmVNC; VS Code (web y desktop) con extensiones de IA listas.
- Home persistente en volumen Docker; labels de Watchtower habilitadas.
- Script `gen_mks_litellm_key` disponible en el workspace para regenerar/aplicar una nueva key de IA.
