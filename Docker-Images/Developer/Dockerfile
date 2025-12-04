# Imagen base con escritorio KDE
FROM ghcr.io/makespacemadrid/coder-mks-desktop:latest

LABEL org.opencontainers.image.title="coder-mks-developer" \
      org.opencontainers.image.description="Coder Desktop extendido con utilidades dev, Docker, IA CLI y tooling de consola" \
      org.opencontainers.image.source="https://github.com/makespacemadrid/coder-workspace-desktop" \
      org.opencontainers.image.url="ghcr.io/makespacemadrid/coder-mks-developer:latest"

USER root

ENV DEBIAN_FRONTEND=noninteractive

# Paquetes adicionales de desarrollo sobre la base desktop
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        # herramientas de desarrollo genéricas
        build-essential \
        pkg-config \
        python3 python3-venv python3-pip pipx \
        # navegador dentro del KasmVNC (via PPA, evita snap)
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
        eza \
        tmux \
        direnv \
        zip unzip p7zip-full \
    && rm -rf /var/lib/apt/lists/*

# KasmVNC viene como módulo de Coder; solo dejamos KDE como session manager
RUN update-alternatives --set x-session-manager /usr/bin/startplasma-x11 || true

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

# Visual Studio Code (repositorio oficial Microsoft)
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg && \
    chmod a+r /etc/apt/keyrings/microsoft.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
      | tee /etc/apt/sources.list.d/vscode.list > /dev/null && \
    apt-get update && \
    apt-get install -y --no-install-recommends code && \
    rm -rf /var/lib/apt/lists/*

ENV PIPX_HOME=/opt/pipx \
    PIPX_BIN_DIR=/usr/local/bin \
    PATH="/usr/local/bin:${PATH}"
