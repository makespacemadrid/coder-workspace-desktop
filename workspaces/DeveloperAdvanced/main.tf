terraform {
  required_providers {
    coder = {
      source = "coder/coder"
    }
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

variable "docker_socket" {
  default     = "unix:///var/run/docker.sock"
  description = "(Optional) Docker socket URI (use unix:// prefix)"
  type        = string
}

locals {
  username        = data.coder_workspace_owner.me.name
  workspace_image = "ghcr.io/makespacemadrid/coder-mks-developer:latest"
}

provider "docker" {
  host = var.docker_socket != "" ? var.docker_socket : null
}

data "coder_provisioner" "me" {}
data "coder_workspace" "me" {}
data "coder_workspace_owner" "me" {}

resource "coder_agent" "main" {
  arch = data.coder_provisioner.me.arch
  os   = "linux"

  startup_script = <<-EOT
    set -e

    # Resolver coder.mksmad.org desde dentro del workspace
    echo "10.0.0.184 coder.mksmad.org" | sudo tee --append /etc/hosts

    # Asegurar /home/coder como HOME efectivo incluso si se ejecuta como root
    sudo mkdir -p /home/coder
    sudo chown "$USER:$USER" /home/coder || true

    # Symlink de opencode cuando se instale bajo /root (start script espera /home/coder/.opencode)
    if [ -d /root/.opencode ] && [ ! -e /home/coder/.opencode ]; then
      sudo ln -s /root/.opencode /home/coder/.opencode || true
    fi

    # Alinear binarios instalados como root (ej. jupyter)
    sudo mkdir -p /home/coder/.local/bin
    for path in /root/.local/bin/jupyter-lab /usr/local/bin/jupyter-lab; do
      if [ -x "$path" ] && [ ! -e /home/coder/.local/bin/jupyter-lab ]; then
        sudo ln -sf "$path" /home/coder/.local/bin/jupyter-lab || true
      fi
    done

    # Inicializar /etc/skel la primera vez
    if [ ! -f ~/.init_done ]; then
      cp -rT /etc/skel ~ || true
      touch ~/.init_done
    fi

    # --------------------------------------------------------------------------------
    # UV: instalador universal para CLIs Python (opcional)
    # --------------------------------------------------------------------------------
    if ! command -v uv >/dev/null 2>&1; then
      echo ">> Installing uv (Python package/CLI installer)..."
      curl -LsSf https://astral.sh/uv/install.sh | sh || true

      # Intentar dejar uv en el PATH del sistema
      if [ -f "/root/.local/bin/uv" ]; then
        sudo ln -sf /root/.local/bin/uv /usr/local/bin/uv || true
      fi
      if [ -f "$HOME/.local/bin/uv" ]; then
        sudo ln -sf "$HOME/.local/bin/uv" /usr/local/bin/uv || true
      fi

      hash -r || true
    fi
  EOT

  env = {
    GIT_AUTHOR_NAME     = coalesce(data.coder_workspace_owner.me.full_name, data.coder_workspace_owner.me.name)
    GIT_AUTHOR_EMAIL    = data.coder_workspace_owner.me.email
    GIT_COMMITTER_NAME  = coalesce(data.coder_workspace_owner.me.full_name, data.coder_workspace_owner.me.name)
    GIT_COMMITTER_EMAIL = data.coder_workspace_owner.me.email
    HOME                = "/home/coder"
  }

  metadata {
    display_name = "CPU Usage"
    key          = "0_cpu_usage"
    script       = "coder stat cpu"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "RAM Usage"
    key          = "1_ram_usage"
    script       = "coder stat mem"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "Home Disk"
    key          = "3_home_disk"
    script       = "coder stat disk --path $${HOME}"
    interval     = 60
    timeout      = 1
  }

  metadata {
    display_name = "CPU Usage (Host)"
    key          = "4_cpu_usage_host"
    script       = "coder stat cpu --host"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "Memory Usage (Host)"
    key          = "5_mem_usage_host"
    script       = "coder stat mem --host"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "Load Average (Host)"
    key          = "6_load_host"
    script       = <<EOT
      echo "`cat /proc/loadavg | awk '{ print $1 }'` `nproc`" | \
      awk '{ printf "%0.2f", $1/$2 }'
    EOT
    interval     = 60
    timeout      = 1
  }

  metadata {
    display_name = "Swap Usage (Host)"
    key          = "7_swap_host"
    script       = <<EOT
      free -b | awk '/^Swap/ { printf("%.1f/%.1f", $3/1024/1024/1024, $2/1024/1024/1024) }'
    EOT
    interval     = 10
    timeout      = 1
  }
}

# ---------------------------------------------------------------
# MÓDULOS DE CODER
# ---------------------------------------------------------------

module "code-server" {
  count    = data.coder_workspace.me.start_count
  source   = "registry.coder.com/coder/code-server/coder"
  version  = "~> 1.0"
  agent_id = coder_agent.main.id
  order    = 1
}

module "git-config" {
  count    = data.coder_workspace.me.start_count
  source   = "registry.coder.com/coder/git-config/coder"
  version  = "1.0.32"
  agent_id = coder_agent.main.id
}

module "coder-login" {
  count    = data.coder_workspace.me.start_count
  source   = "registry.coder.com/coder/coder-login/coder"
  version  = "1.1.1"
  agent_id = coder_agent.main.id
}

module "tmux" {
  source   = "registry.coder.com/anomaly/tmux/coder"
  version  = "1.0.2"
  agent_id = coder_agent.main.id
}

module "kasmvnc" {
  count               = data.coder_workspace.me.start_count
  source              = "registry.coder.com/coder/kasmvnc/coder"
  version             = "1.2.6"
  agent_id            = coder_agent.main.id
  desktop_environment = "xfce"
  subdomain           = true
}

module "github-upload-public-key" {
  count    = 0 # Deshabilitado temporalmente (external-auth no configurado)
  source   = "registry.coder.com/coder/github-upload-public-key/coder"
  version  = "1.0.32"
  agent_id = coder_agent.main.id
}

module "jupyterlab" {
  count = 0
  # Deshabilitado temporalmente
  source   = "registry.coder.com/coder/jupyterlab/coder"
  version  = "1.2.1"
  agent_id = coder_agent.main.id
}

module "cursor" {
  count    = data.coder_workspace.me.start_count
  source   = "registry.coder.com/coder/cursor/coder"
  version  = "1.3.3"
  agent_id = coder_agent.main.id
}

module "filebrowser" {
  count    = data.coder_workspace.me.start_count
  source   = "registry.coder.com/coder/filebrowser/coder"
  version  = "1.1.3"
  agent_id = coder_agent.main.id
}

module "opencode" {
  source   = "registry.coder.com/coder-labs/opencode/coder"
  version  = "0.1.1"
  agent_id = coder_agent.main.id
  workdir  = "/home/coder/"
}

# ---------------------------------------------------------------
# HOME PERSISTENTE
# ---------------------------------------------------------------

resource "docker_volume" "home_volume" {
  name = "coder-${data.coder_workspace.me.id}-home"

  lifecycle {
    ignore_changes = all
  }

  labels {
    label = "coder.owner"
    value = data.coder_workspace_owner.me.name
  }
  labels {
    label = "coder.owner_id"
    value = data.coder_workspace_owner.me.id
  }
  labels {
    label = "coder.workspace_id"
    value = data.coder_workspace.me.id
  }
  labels {
    label = "coder.workspace_name_at_creation"
    value = data.coder_workspace.me.name
  }
}

# ---------------------------------------------------------------
# CONTENEDOR PRINCIPAL DEL WORKSPACE
# ---------------------------------------------------------------

resource "docker_container" "workspace" {
  image = local.workspace_image

  name     = "coder-${data.coder_workspace_owner.me.name}-${lower(data.coder_workspace.me.name)}"
  hostname = data.coder_workspace.me.name

  user = "coder"
  # Acceso directo a la red del host (sin mapeo de puertos)
  network_mode = "host"

  entrypoint = [
    "sh",
    "-c",
    replace(coder_agent.main.init_script, "/localhost|127\\.0\\.0\\.1/", "host.docker.internal")
  ]

  env = [
    "CODER_AGENT_TOKEN=${coder_agent.main.token}",
    "TZ=Europe/Madrid",
    "NVIDIA_VISIBLE_DEVICES=all",
    "NVIDIA_DRIVER_CAPABILITIES=compute,utility,graphics,video"
  ]

  # Permiso para usar Docker del host
  group_add = ["995"]

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }

  # Para mejorar KasmVNC y navegadores
  shm_size = 2 * 1024 * 1024 * 1024

  volumes {
    container_path = "/home/coder"
    volume_name    = docker_volume.home_volume.name
  }

  labels {
    label = "coder.owner"
    value = data.coder_workspace_owner.me.name
  }
  labels {
    label = "coder.owner_id"
    value = data.coder_workspace_owner.me.id
  }
  labels {
    label = "coder.workspace_id"
    value = data.coder_workspace.me.id
  }
  labels {
    label = "coder.workspace_name"
    value = data.coder_workspace.me.name
  }
}
