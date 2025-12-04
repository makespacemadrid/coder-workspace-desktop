# Base desktop image with MATE for Coder workspaces
FROM codercom/enterprise-base:ubuntu

LABEL org.opencontainers.image.title="coder-mks-desktop" \
      org.opencontainers.image.description="Base desktop image (MATE) for Coder workspaces" \
      org.opencontainers.image.source="https://github.com/makespacemadrid/coder-workspace-desktop" \
      org.opencontainers.image.url="ghcr.io/makespacemadrid/coder-mks-desktop:latest"

USER root

ENV DEBIAN_FRONTEND=noninteractive

# Core deps + MATE desktop + Firefox (mozillateam)
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
        # navegador
        firefox \
        # escritorio MATE (sesión X11)
        mate-desktop-environment-core \
        mate-session-manager \
        marco \
        mate-panel \
        mate-control-center \
        mate-terminal \
        caja \
    && rm -rf /var/lib/apt/lists/*

# Wrapper para KasmVNC: si se pide "xfce", arrancar MATE
RUN printf '#!/bin/sh\nexec mate-session\n' > /usr/local/bin/startxfce4 && chmod +x /usr/local/bin/startxfce4

# Locales por defecto
RUN locale-gen es_ES.UTF-8 en_US.UTF-8 && \
    update-locale LANG=es_ES.UTF-8

ENV LANG=es_ES.UTF-8 \
    LC_ALL=es_ES.UTF-8
