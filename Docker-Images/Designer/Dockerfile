# Imagen base para diseño 2D/3D y electrónica (MakeSpace)
FROM codercom/enterprise-desktop:ubuntu

LABEL org.opencontainers.image.title="coder-mks-design" \
      org.opencontainers.image.description="Entorno de escritorio para diseño 2D/3D y electrónica (FreeCAD, Inkscape, GIMP, KiCad, Blender, PrusaSlicer, OpenSCAD)" \
      org.opencontainers.image.source="https://github.com/makespacemadrid/coder-workspace-desktop" \
      org.opencontainers.image.url="ghcr.io/makespacemadrid/coder-mks-design:latest"

USER root

ENV DEBIAN_FRONTEND=noninteractive

# Paquetes base, escritorio y apps de diseño
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common && \
    add-apt-repository -y ppa:mozillateam/ppa && \
    printf 'Package: firefox*\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1001\n' > /etc/apt/preferences.d/mozillateam-firefox && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl wget \
        git \
        sudo \
        locales tzdata \
        # deps X11 / audio / GL
        dbus-x11 \
        xauth \
        x11-xserver-utils \
        libasound2t64 \
        libgl1 \
        libgl1-mesa-dri \
        mesa-utils \
        # utilidades básicas
        build-essential \
        pkg-config \
        python3 python3-venv python3-pip pipx \
        zip unzip p7zip-full \
        # navegador para KasmVNC
        firefox \
        # Herramientas de diseño 2D/3D y electrónica
        inkscape \
        gimp \
        krita \
        blender \
        freecad \
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

# OrcaSlicer (AppImage) y LaserGRBL (Wine)
RUN ORCA_VERSION="2.1.1" && \
    ORCA_URL="https://github.com/SoftFever/OrcaSlicer/releases/download/v${ORCA_VERSION}/OrcaSlicer_Linux_V${ORCA_VERSION}.AppImage" && \
    curl -fL "${ORCA_URL}" -o /usr/local/bin/orcaslicer && \
    chmod +x /usr/local/bin/orcaslicer && \
    mkdir -p /opt/lasergrbl && \
    LASERGRBL_URL="https://github.com/arkypita/LaserGRBL/releases/download/v5.7.10/LaserGRBL.5.7.10.zip" && \
    curl -fL "${LASERGRBL_URL}" -o /opt/lasergrbl/LaserGRBL.zip && \
    apt-get update && apt-get install -y --no-install-recommends unzip && \
    unzip /opt/lasergrbl/LaserGRBL.zip -d /opt/lasergrbl && \
    rm /opt/lasergrbl/LaserGRBL.zip && \
    rm -rf /var/lib/apt/lists/*

# Locales
RUN locale-gen es_ES.UTF-8 en_US.UTF-8 && \
    update-locale LANG=es_ES.UTF-8

ENV LANG=es_ES.UTF-8 \
    LC_ALL=es_ES.UTF-8
