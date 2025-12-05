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
        cifs-utils \
        nfs-common \
        sshfs \
        geany \
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

# Utilidades NVIDIA para poder usar `nvidia-smi` cuando hay GPUs
RUN set -e; \
    apt-get update; \
    if ! apt-get install -y --no-install-recommends nvidia-utils-535; then \
      if ! apt-get install -y --no-install-recommends nvidia-utils-530; then \
        apt-get install -y --no-install-recommends nvidia-utils-525 || true; \
      fi; \
    fi; \
    rm -rf /var/lib/apt/lists/*

# GitHub Desktop (shiftkey build) y Claude Desktop (unofficial build)
ARG GITHUB_DESKTOP_VERSION=3.4.13-linux1
ARG GITHUB_DESKTOP_DEB_URL=https://github.com/shiftkey/desktop/releases/download/release-${GITHUB_DESKTOP_VERSION}/GitHubDesktop-linux-amd64-${GITHUB_DESKTOP_VERSION}.deb
ARG CLAUDE_DESKTOP_VERSION=0.14.10
ARG CLAUDE_DESKTOP_DEB_URL=https://github.com/aaddrick/claude-desktop-debian/releases/download/v1.1.10%2Bclaude${CLAUDE_DESKTOP_VERSION}/claude-desktop_${CLAUDE_DESKTOP_VERSION}_amd64.deb
RUN curl -fsSL "${GITHUB_DESKTOP_DEB_URL}" -o /tmp/github-desktop.deb && \
    curl -fsSL "${CLAUDE_DESKTOP_DEB_URL}" -o /tmp/claude-desktop.deb && \
    apt-get update && \
    apt-get install -y --no-install-recommends /tmp/github-desktop.deb /tmp/claude-desktop.deb && \
    rm -rf /var/lib/apt/lists/* /tmp/github-desktop.deb /tmp/claude-desktop.deb

# Electron apps dentro de contenedores Docker necesitan desactivar el sandbox
# (no hay user namespaces). Los wrappers añaden --no-sandbox y pistas de Ozone.
ENV ELECTRON_DISABLE_SANDBOX=1 \
    ELECTRON_OZONE_PLATFORM_HINT=auto
RUN <<'EOSH'
set -e
wrap() {
  local name="$1"; local target="$2"; local extra="$3"
  if [ -x "$target" ]; then
    mv "$name" "${name}.real" || true
    cat > "$name" <<SHWRAP
#!/bin/sh
exec env ELECTRON_DISABLE_SANDBOX=1 ELECTRON_OZONE_PLATFORM_HINT="${ELECTRON_OZONE_PLATFORM_HINT:-auto}" \
  "$target" --no-sandbox --disable-gpu-sandbox --disable-setuid-sandbox --disable-seccomp-filter-sandbox --no-zygote $EXTRA_FLAGS "$@"
SHWRAP
    chmod +x "$name"
  fi
}
TARGET_BIN=/usr/lib/github-desktop/github-desktop EXTRA_FLAGS="--password-store=basic" wrap /usr/bin/github-desktop /usr/lib/github-desktop/github-desktop
TARGET_BIN=/usr/share/claude-desktop/claude-desktop EXTRA_FLAGS="--disable-gpu" wrap /usr/bin/claude-desktop /usr/share/claude-desktop/claude-desktop
TARGET_BIN=/usr/share/code/bin/code EXTRA_FLAGS="" wrap /usr/bin/code /usr/share/code/bin/code
EOSH

# AppImage Pool (gestor de AppImages con actualizaciones e integración en menú)
ARG APPIMAGEPOOL_VERSION=5.0.0
ARG APPIMAGEPOOL_URL=https://github.com/prateekmedia/appimagepool/releases/download/${APPIMAGEPOOL_VERSION}/AppImagePool-${APPIMAGEPOOL_VERSION}-x86_64.AppImage
RUN mkdir -p /opt/appimagepool && \
    curl -fsSL "${APPIMAGEPOOL_URL}" -o /opt/appimagepool/AppImagePool.AppImage && \
    chmod +x /opt/appimagepool/AppImagePool.AppImage && \
    ln -sf /opt/appimagepool/AppImagePool.AppImage /usr/local/bin/appimagepool && \
    cat > /usr/share/applications/appimagepool.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=AppImage Pool
Exec=appimagepool
Icon=appimagepool
Categories=Utility;
EOF

# Accesos directos en el escritorio por defecto
RUN set -e; \
    mkdir -p /etc/skel/Desktop && \
    for f in code.desktop github-desktop.desktop claude-desktop.desktop firefox.desktop geany.desktop appimagepool.desktop; do \
      src="/usr/share/applications/$f"; \
      if [ -f "$src" ]; then ln -sf "$src" "/etc/skel/Desktop/$f"; fi; \
    done; \
    chmod +x /etc/skel/Desktop/*.desktop || true

ENV PIPX_HOME=/opt/pipx \
    PIPX_BIN_DIR=/usr/local/bin \
    PATH="/usr/local/bin:${PATH}"
