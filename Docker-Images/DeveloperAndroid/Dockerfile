# Developer Android image with KDE desktop and Android SDK
FROM ghcr.io/makespacemadrid/coder-mks-desktop-kde:latest

LABEL org.opencontainers.image.title="coder-mks-developer-android" \
      org.opencontainers.image.description="Coder Desktop KDE con toolchain Android (SDK/CLI), Node 20 y VS Code" \
      org.opencontainers.image.source="https://github.com/makespacemadrid/coder-workspace-desktop" \
      org.opencontainers.image.url="ghcr.io/makespacemadrid/coder-mks-developer-android:latest" \
      com.centurylinklabs.watchtower.enable="true" \
      com.centurylinklabs.watchtower.scope="coder-workspaces" \
      com.centurylinklabs.watchtower.lifecycle="rolling"

USER root

ENV DEBIAN_FRONTEND=noninteractive

# Paquetes base para desarrollo Android + utilidades
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        pkg-config \
        openjdk-17-jdk \
        python3 python3-venv python3-pip pipx \
        unzip zip \
        git git-lfs \
        jq \
        curl wget \
        ca-certificates \
        libc6:i386 libstdc++6:i386 libgcc-s1:i386 libz1:i386 libncurses5:i386 \
        libpulse0 \
        adb \
        dnsutils net-tools iputils-ping \
        ripgrep fzf \
        direnv \
        bash-completion \
        nano \
        lsof \
        htop \
        tmux \
        byobu \
        pulseaudio pulseaudio-utils alsa-utils \
        libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Node.js 20 + package managers (para React Native/JS tooling)
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

# Visual Studio Code
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg && \
    chmod a+r /etc/apt/keyrings/microsoft.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
      | tee /etc/apt/sources.list.d/vscode.list > /dev/null && \
    apt-get update && \
    apt-get install -y --no-install-recommends code && \
    rm -rf /var/lib/apt/lists/*

# Android SDK commandline tools + componentes principales
ENV ANDROID_HOME=/opt/android-sdk \
    ANDROID_SDK_ROOT=/opt/android-sdk \
    ANDROID_USER_HOME=/home/coder/.android \
    PATH=$PATH:/opt/android-sdk/platform-tools:/opt/android-sdk/cmdline-tools/latest/bin:/opt/android-sdk/emulator

ARG ANDROID_SDK_VERSION=11076708
RUN mkdir -p /opt/android-sdk/cmdline-tools && \
    curl -fsSL "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip" -o /tmp/cmdline-tools.zip && \
    unzip -q /tmp/cmdline-tools.zip -d /opt/android-sdk/cmdline-tools && \
    mv /opt/android-sdk/cmdline-tools/cmdline-tools /opt/android-sdk/cmdline-tools/latest && \
    rm /tmp/cmdline-tools.zip && \
    yes | /opt/android-sdk/cmdline-tools/latest/bin/sdkmanager --licenses >/dev/null || true && \
    /opt/android-sdk/cmdline-tools/latest/bin/sdkmanager --update && \
    /opt/android-sdk/cmdline-tools/latest/bin/sdkmanager \
      "platform-tools" \
      "build-tools;34.0.0" \
      "platforms;android-34" \
      "emulator" \
      "cmdline-tools;latest" && \
    chown -R coder:coder /opt/android-sdk

# Extensiones VS Code preinstaladas
RUN su - coder -c 'set -e; \
  EXT_LIST="anthropic.claude-code opencodeai.opencode google.gemini-code-assistant qwen-team.qwen-vscode openai.openai ms-vscode.cpptools"; \
  for ext in $EXT_LIST; do \
    code --install-extension "$ext" --force --user-data-dir /home/coder/.vscode/data --extensions-dir /home/coder/.vscode/extensions || true; \
  done; \
  mkdir -p /home/coder/.vscode-server/extensions'

# Electron sandbox workaround for VS Code
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
TARGET_BIN=/usr/share/code/bin/code EXTRA_FLAGS="" wrap /usr/bin/code /usr/share/code/bin/code
EOSH
