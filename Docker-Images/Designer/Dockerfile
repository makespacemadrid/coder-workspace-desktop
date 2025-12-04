# Imagen base para diseño 2D/3D y electrónica (MakeSpace) basada en coder-mks-desktop-kde
FROM ghcr.io/makespacemadrid/coder-mks-desktop-kde:latest

LABEL org.opencontainers.image.title="coder-mks-design" \
      org.opencontainers.image.description="Entorno de escritorio para diseño 2D/3D y electrónica (FreeCAD, Inkscape, GIMP, KiCad, Blender, PrusaSlicer, OpenSCAD)" \
      org.opencontainers.image.source="https://github.com/makespacemadrid/coder-workspace-desktop" \
      org.opencontainers.image.url="ghcr.io/makespacemadrid/coder-mks-design:latest"

USER root

ENV DEBIAN_FRONTEND=noninteractive

# Paquetes adicionales de diseño (la base ya incluye KDE + Firefox)
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common && \
    add-apt-repository -y universe && \
    add-apt-repository -y ppa:mozillateam/ppa && \
    add-apt-repository -y ppa:freecad-maintainers/freecad-stable && \
    printf 'Package: firefox*\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1001\n' > /etc/apt/preferences.d/mozillateam-firefox && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        pkg-config \
        python3 python3-venv python3-pip pipx \
        zip unzip p7zip-full \
        inkscape \
        gimp \
        krita \
        freecad \
        freecad-common \
        openscad \
        prusa-slicer \
        librecad \
        meshlab \
        kicad \
        kicad-demos \
        kicad-symbols \
        kicad-footprints \
        kicad-packages3d \
        kicad-templates \
        fritzing \
        fritzing-data \
        fritzing-parts \
        simulide \
        wine64 \
        wine32 \
        winbind \
    && rm -rf /var/lib/apt/lists/*

# OrcaSlicer (AppImage), LaserGRBL (Wine) y VisiCut (.deb)
RUN ORCA_VERSION="2.3.1" && \
    ORCA_ASSET="OrcaSlicer_Linux_AppImage_Ubuntu2404_V${ORCA_VERSION}.AppImage" && \
    ORCA_URL="https://github.com/OrcaSlicer/OrcaSlicer/releases/download/v${ORCA_VERSION}/${ORCA_ASSET}" && \
    curl -fL "${ORCA_URL}" -o /usr/local/bin/orcaslicer && \
    chmod +x /usr/local/bin/orcaslicer && \
    mkdir -p /opt/lasergrbl && \
    LASERGRBL_VERSION="7.14.1" && \
    LASERGRBL_URL="https://github.com/arkypita/LaserGRBL/releases/download/v${LASERGRBL_VERSION}/install.exe" && \
    curl -fL "${LASERGRBL_URL}" -o /opt/lasergrbl/LaserGRBL-install.exe && \
    curl -fL "https://github.com/t-oster/VisiCut/releases/download/2.1/visicut_2.1%2Bdevel-1_all.deb" -o /tmp/visicut.deb && \
    apt-get update && apt-get install -y --no-install-recommends /tmp/visicut.deb && \
    rm /tmp/visicut.deb && \
    rm -rf /var/lib/apt/lists/*

# Locales
RUN locale-gen es_ES.UTF-8 en_US.UTF-8 && \
    update-locale LANG=es_ES.UTF-8

ENV LANG=es_ES.UTF-8 \
    LC_ALL=es_ES.UTF-8

# Utilidades NVIDIA para `nvidia-smi` cuando se habilitan GPUs
RUN set -e; \
    apt-get update; \
    if ! apt-get install -y --no-install-recommends nvidia-utils-535; then \
      if ! apt-get install -y --no-install-recommends nvidia-utils-530; then \
        apt-get install -y --no-install-recommends nvidia-utils-525 || true; \
      fi; \
    fi; \
    rm -rf /var/lib/apt/lists/*

# Desactivar bloqueo/ahorro de pantalla (KDE) y dejar accesos directos en Desktop
RUN printf '[Daemon]\nTimeout=0\nLockOnResume=false\nLockOnSuspend=false\nAutolock=false\n' > /etc/xdg/kscreenlockerrc && \
    mkdir -p /etc/skel/Desktop && \
    for f in firefox.desktop freecad.desktop inkscape.desktop org.gimp.GIMP.desktop krita.desktop kicad.desktop openscad.desktop prusa-slicer.desktop librecad.desktop meshlab.desktop; do \
      src="/usr/share/applications/$f"; \
      if [ -f "$src" ]; then ln -sf "$src" "/etc/skel/Desktop/$f"; fi; \
    done && \
    chmod +x /etc/skel/Desktop/*.desktop || true
