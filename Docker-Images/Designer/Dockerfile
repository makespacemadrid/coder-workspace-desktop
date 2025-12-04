# Imagen base para diseño 2D/3D y electrónica (MakeSpace) con KDE Plasma
FROM codercom/enterprise-base:ubuntu

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
    add-apt-repository -y universe && \
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
        # escritorio KDE Plasma (sesión completa con gestor de ventanas)
        kde-plasma-desktop \
        kwin-x11 \
        plasma-workspace \
        konsole \
        dolphin \
        # Herramientas de diseño 2D/3D y electrónica
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
