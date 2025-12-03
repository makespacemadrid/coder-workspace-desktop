# Imagen base oficial de Coder con escritorio
FROM codercom/enterprise-desktop:ubuntu

LABEL org.opencontainers.image.title="coder-mks-develop" \
      org.opencontainers.image.description="Coder Desktop extendido con utilidades dev, Docker, IA CLI y tooling de consola" \
      org.opencontainers.image.source="https://github.com/darkjavi/coder-workspace-desktop"

USER root

ENV DEBIAN_FRONTEND=noninteractive

# Paquetes comunes + dependencias típicas de KasmVNC y servicios gráficos
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl wget \
        git \
        sudo \
        locales tzdata \
        # deps X11 / audio / GL que suelen pedir Kasm y apps gráficas
        dbus-x11 \
        xauth \
        x11-xserver-utils \
        libasound2 \
        libgl1 \
        libgl1-mesa-dri \
        mesa-utils \
        # herramientas de desarrollo genéricas
        build-essential \
        pkg-config \
        python3 python3-venv python3-pip pipx uv \
        # navegador dentro del KasmVNC
        firefox \
        # utilidades extra y tooling de consola
        jq \
        gnupg \
        git-lfs \
        pre-commit \
        dnsutils \
        net-tools \
        lsof \
        htop \
        ripgrep \
        fzf \
        bat \
        exa \
        tmux \
        direnv \
        zip unzip p7zip-full \
    && rm -rf /var/lib/apt/lists/*

# Locales (puedes ajustar a gusto)
RUN locale-gen es_ES.UTF-8 en_US.UTF-8 && \
    update-locale LANG=es_ES.UTF-8

ENV LANG=es_ES.UTF-8 \
    LC_ALL=es_ES.UTF-8

# Docker Engine y Docker Compose desde el repo oficial de Docker
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
      | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/*

# GitHub CLI (repositorio oficial)
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /etc/apt/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install -y --no-install-recommends gh && \
    rm -rf /var/lib/apt/lists/*

# Node.js 20 y las CLIs de IA para trabajo con código
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" \
      | tee /etc/apt/sources.list.d/nodesource.list > /dev/null && \
    apt-get update && \
    apt-get install -y --no-install-recommends nodejs && \
    npm install -g --omit=dev --no-update-notifier --no-fund \
        pnpm \
        yarn \
        @openai/codex \
        @anthropic-ai/claude-code \
        @google/gemini-cli && \
    npm cache clean --force && \
    rm -rf /var/lib/apt/lists/*

ENV PIPX_HOME=/opt/pipx \
    PIPX_BIN_DIR=/usr/local/bin \
    PATH="/usr/local/bin:${PATH}"
