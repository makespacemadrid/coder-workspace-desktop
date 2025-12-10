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
  default     = ""
  description = "(Optional) Docker socket URI (no se usa por defecto)"
  type        = string
}

# Parámetro para GPUs opcionales
data "coder_parameter" "enable_gpu" {
  name         = "enable_gpu"
  display_name = "GPU (si disponible)"
  description  = "Expone GPUs al contenedor; requiere host con GPU configurada."
  type         = "bool"
  default      = true
  mutable      = true
}

data "coder_parameter" "git_repo_url" {
  name         = "git_repo_url"
  display_name = "Repositorio Git (opcional)"
  description  = "URL para clonar en ~/projects/<repo> en el primer arranque."
  type         = "string"
  default      = ""
  mutable      = true
}

data "coder_parameter" "home_host_path" {
  name         = "home_host_path"
  display_name = "Ruta host para /home (opcional)"
  description  = "Monta /home/coder desde el host en lugar del volumen Docker persistente. Deja vacío para usar el volumen por defecto."
  type         = "string"
  default      = ""
  mutable      = true
}

data "coder_parameter" "home_host_uid" {
  name         = "home_host_uid"
  display_name = "UID para /home host (opcional)"
  description  = "UID de la carpeta /home en el host; se usará como usuario del contenedor. Deja vacío para usar el usuario coder."
  type         = "string"
  default      = ""
  mutable      = true
}

data "coder_parameter" "home_volume_name" {
  name         = "home_volume_name"
  display_name = "Nombre volumen /home (opcional)"
  description  = "Nombre del volumen Docker para /home/coder cuando no montas ruta host. Si lo dejas vacío, usa el nombre por defecto."
  type         = "string"
  default      = ""
  mutable      = true
}

data "coder_parameter" "home_volume_existing" {
  name         = "home_volume_existing"
  display_name = "Volumen /home existente (opcional)"
  description  = "Volumen Docker ya creado para usarlo en /home/coder. Si lo dejas vacío se creará un volumen nuevo."
  type         = "string"
  default      = ""
  mutable      = true
}

data "coder_parameter" "host_data_path" {
  name         = "host_data_path"
  display_name = "Ruta host para /home/coder/host-data (opcional)"
  description  = "Monta una ruta del host en /home/coder/host-data dentro del contenedor. Deja vacío para omitir."
  type         = "string"
  default      = ""
  mutable      = true
}

data "coder_parameter" "opencode_provider_url" {
  name         = "opencode_provider_url"
  display_name = "OpenCode: provider URL (opcional)"
  description  = "Base URL compatible con OpenAI (ej. https://api.tu-proveedor.com/v1). Si lo dejas vacío se usa http://iapi.mksmad.org y se autoprovisiona una key MakeSpace (30 días)."
  type         = "string"
  default      = ""
  mutable      = true
}

data "coder_parameter" "opencode_api_key" {
  name         = "opencode_api_key"
  display_name = "OpenCode: API key (opcional)"
  description  = "API key para el proveedor OpenAI compatible. Si la dejas vacía se generará una llave MakeSpace válida 30 días."
  type         = "string"
  default      = ""
  mutable      = true
}

locals {
  username        = data.coder_workspace_owner.me.name
  workspace_image = "ghcr.io/makespacemadrid/coder-mks-design:latest"
  enable_gpu      = data.coder_parameter.enable_gpu.value
  home_host_path  = trimspace(data.coder_parameter.home_host_path.value)
  home_host_uid   = trimspace(data.coder_parameter.home_host_uid.value)
  host_data_path  = trimspace(data.coder_parameter.host_data_path.value)
  home_volume_existing = trimspace(data.coder_parameter.home_volume_existing.value)
  home_volume_name     = trimspace(data.coder_parameter.home_volume_name.value)
  home_volume_resolved = coalesce(
    local.home_volume_existing != "" ? local.home_volume_existing : null,
    local.home_volume_name != "" ? local.home_volume_name : null,
    "coder-${data.coder_workspace.me.id}-home"
  )
  vscode_extensions = [
    "anthropic.claude-code",
    "opencodeai.opencode",
    "google.gemini-code-assistant",
    "qwen-team.qwen-vscode",
    "openai.openai"
  ]
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

    # Asegurar permisos de FUSE
    sudo usermod -aG fuse "$USER" || true
    if [ -e /dev/fuse ]; then
      sudo chown root:fuse /dev/fuse || true
      sudo chmod 666 /dev/fuse || true
    fi

    # Configurar PulseAudio para soporte de audio en KasmVNC
    sudo usermod -aG audio "$USER" || true
    mkdir -p ~/.config/pulse
    if [ ! -f ~/.config/pulse/client.conf ]; then
      cat > ~/.config/pulse/client.conf <<'PULSECFG'
autospawn = yes
daemon-binary = /usr/bin/pulseaudio
enable-shm = false
PULSECFG
    fi
    # Iniciar PulseAudio si no está corriendo
    if ! pgrep -u "$USER" pulseaudio >/dev/null 2>&1; then
      pulseaudio --start --exit-idle-time=-1 || true
    fi

    # KasmVNC busca startkde; en Plasma moderno es startplasma-x11
    if [ -x /usr/bin/startplasma-x11 ] && [ ! -x /usr/bin/startkde ]; then
      sudo ln -sf /usr/bin/startplasma-x11 /usr/bin/startkde
    fi

    # Inicializar /etc/skel la primera vez
    if [ ! -f ~/.init_done ]; then
      cp -rT /etc/skel ~ || true
      touch ~/.init_done
    fi

    # Refrescar accesos directos en el escritorio (si faltan)
    mkdir -p ~/Desktop
    for f in firefox.desktop blender.desktop freecad.desktop inkscape.desktop org.gimp.GIMP.desktop krita.desktop kicad.desktop openscad.desktop prusa-slicer.desktop librecad.desktop meshlab.desktop visicut.desktop geany.desktop appimagepool.desktop orcaslicer.desktop simulide.desktop; do
      src="/usr/share/applications/$f"
      if [ -f "$src" ] && [ ! -e "$HOME/Desktop/$f" ]; then
        ln -sf "$src" "$HOME/Desktop/$f"
      fi
    done
    chmod +x ~/Desktop/*.desktop 2>/dev/null || true

    # Autoprovisionar clave OpenCode MakeSpace si falta
    if [ -z "$${OPENCODE_PROVIDER_URL:-}" ]; then
      OPENCODE_PROVIDER_URL="http://iapi.mksmad.org"
      export OPENCODE_PROVIDER_URL
    fi
    if [ -z "$${OPENCODE_API_KEY:-}" ]; then
      KEY_ENDPOINT="https://prod8n.mksmad.org/webhook/94b9b71a-dc18-4c69-88d6-5b02100bf577"
      alias="coder-$(tr -dc 0-9 </dev/urandom 2>/dev/null | head -c 8 | sed 's/^$/00000000/')"
      payload=$(printf '{"email":"%s","alias":"%s"}' "$${CODER_USER_EMAIL:-}" "$alias")
      resp=$(curl -fsSL -X POST "$KEY_ENDPOINT" -H "Content-Type: application/json" -d "$payload" 2>/dev/null || true)
      key=$(printf '%s' "$resp" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("key",""))' 2>/dev/null || true)
      if [ -n "$key" ]; then
        OPENCODE_API_KEY="$key"
        export OPENCODE_API_KEY
        mkdir -p /home/coder/.opencode
        printf "%s" "$key" > /home/coder/.opencode/.latest_mks_key || true
        printf "%s" "$payload" > /home/coder/.opencode/.latest_mks_request || true
      fi
    fi

    # Script para regenerar y aplicar nueva key de MakeSpace
    sudo tee /usr/local/bin/gen_mks_litellm_key >/dev/null <<'GENMKS'
#!/usr/bin/env bash
set -euo pipefail
KEY_ENDPOINT="https://prod8n.mksmad.org/webhook/94b9b71a-dc18-4c69-88d6-5b02100bf577"
PROVIDER="${OPENCODE_PROVIDER_URL:-http://iapi.mksmad.org}"
EMAIL="${CODER_USER_EMAIL:-}"
alias="coder-$(tr -dc 0-9 </dev/urandom 2>/dev/null | head -c 8 | sed 's/^$/00000000/')"
if [ -z "$EMAIL" ]; then
  echo "Falta CODER_USER_EMAIL para solicitar la key" >&2
  exit 1
fi
payload=$(printf '{"email":"%s","alias":"%s"}' "$EMAIL" "$alias")
resp=$(curl -fsSL -X POST "$KEY_ENDPOINT" -H "Content-Type: application/json" -d "$payload")
key=$(printf '%s' "$resp" | python3 - <<'PY'
import json,sys
try:
  print(json.load(sys.stdin).get("key",""))
except Exception:
  print("")
PY
)
if [ -z "$key" ]; then
  echo "No se obtuvo key de MakeSpace" >&2
  exit 1
fi
export OPENCODE_API_KEY="$key"
export OPENCODE_PROVIDER_URL="$PROVIDER"
mkdir -p /home/coder/.opencode
printf "%s" "$key" > /home/coder/.opencode/.latest_mks_key || true
printf "%s" "$payload" > /home/coder/.opencode/.latest_mks_request || true
python3 - <<'PY'
import json,os
path="/home/coder/.opencode/opencode.json"
data={}
if os.path.exists(path):
  try:
    with open(path) as f:
      data=json.load(f)
  except Exception:
    data={}
prov=data.setdefault("provider",{}).setdefault("custom",{}).setdefault("options",{})
prov["baseURL"]=os.environ.get("OPENCODE_PROVIDER_URL","http://iapi.mksmad.org")
prov["apiKey"]=os.environ.get("OPENCODE_API_KEY","")
data.setdefault("default_provider","custom")
os.makedirs(os.path.dirname(path),exist_ok=True)
with open(path,"w") as f:
  json.dump(data,f,indent=2)
PY
ln -sf /home/coder/.opencode/opencode.json /home/coder/.opencode/config.json || true
echo "Nueva key guardada y aplicada"
GENMKS
    sudo chmod +x /usr/local/bin/gen_mks_litellm_key || true

    # Sembrar extensiones en VS Code Server (para conexiones remotas)
    if [ -n "$${VSCODE_EXTENSIONS:-}" ]; then
      mkdir -p "$HOME/.vscode-server/extensions"
      for server_bin in "$HOME"/.vscode-server/bin/*/bin/code-server; do
        if [ -x "$server_bin" ]; then
          for ext in $${VSCODE_EXTENSIONS}; do
            "$server_bin" --install-extension "$ext" --force --extensions-dir "$HOME/.vscode-server/extensions" || true
          done
        fi
      done
    fi

    # Config inicial de OpenCode (opcional)
    if [ -n "$${OPENCODE_PROVIDER_URL:-}" ] && [ -n "$${OPENCODE_API_KEY:-}" ]; then
      mkdir -p /home/coder/.opencode
      cat > /home/coder/.opencode/opencode.json <<'JSONCFG'
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": [
    "opencode-openai-codex-auth@4.0.2"
  ],
  "provider": {
    "openai": {
      "options": {
        "reasoningEffort": "medium",
        "reasoningSummary": "auto",
        "textVerbosity": "medium",
        "include": [
          "reasoning.encrypted_content"
        ],
        "store": false
      },
      "models": {
        "gpt-5.1-codex-low": {
          "name": "GPT 5.1 Codex Low (OAuth)",
          "limit": {
            "context": 272000,
            "output": 128000
          },
          "options": {
            "reasoningEffort": "low",
            "reasoningSummary": "auto",
            "textVerbosity": "medium",
            "include": [
              "reasoning.encrypted_content"
            ],
            "store": false
          }
        },
        "gpt-5.1-codex-medium": {
          "name": "GPT 5.1 Codex Medium (OAuth)",
          "limit": {
            "context": 272000,
            "output": 128000
          },
          "options": {
            "reasoningEffort": "medium",
            "reasoningSummary": "auto",
            "textVerbosity": "medium",
            "include": [
              "reasoning.encrypted_content"
            ],
            "store": false
          }
        },
        "gpt-5.1-codex-high": {
          "name": "GPT 5.1 Codex High (OAuth)",
          "limit": {
            "context": 272000,
            "output": 128000
          },
          "options": {
            "reasoningEffort": "high",
            "reasoningSummary": "detailed",
            "textVerbosity": "medium",
            "include": [
              "reasoning.encrypted_content"
            ],
            "store": false
          }
        },
        "gpt-5.1-codex-max": {
          "name": "GPT 5.1 Codex Max (OAuth)",
          "limit": {
            "context": 272000,
            "output": 128000
          },
          "options": {
            "reasoningEffort": "high",
            "reasoningSummary": "detailed",
            "textVerbosity": "medium",
            "include": [
              "reasoning.encrypted_content"
            ],
            "store": false
          }
        },
        "gpt-5.1-codex-max-low": {
          "name": "GPT 5.1 Codex Max Low (OAuth)",
          "limit": {
            "context": 272000,
            "output": 128000
          },
          "options": {
            "reasoningEffort": "low",
            "reasoningSummary": "detailed",
            "textVerbosity": "medium",
            "include": [
              "reasoning.encrypted_content"
            ],
            "store": false
          }
        },
        "gpt-5.1-codex-max-medium": {
          "name": "GPT 5.1 Codex Max Medium (OAuth)",
          "limit": {
            "context": 272000,
            "output": 128000
          },
          "options": {
            "reasoningEffort": "medium",
            "reasoningSummary": "detailed",
            "textVerbosity": "medium",
            "include": [
              "reasoning.encrypted_content"
            ],
            "store": false
          }
        },
        "gpt-5.1-codex-max-high": {
          "name": "GPT 5.1 Codex Max High (OAuth)",
          "limit": {
            "context": 272000,
            "output": 128000
          },
          "options": {
            "reasoningEffort": "high",
            "reasoningSummary": "detailed",
            "textVerbosity": "medium",
            "include": [
              "reasoning.encrypted_content"
            ],
            "store": false
          }
        },
        "gpt-5.1-codex-max-xhigh": {
          "name": "GPT 5.1 Codex Max Extra High (OAuth)",
          "limit": {
            "context": 272000,
            "output": 128000
          },
          "options": {
            "reasoningEffort": "xhigh",
            "reasoningSummary": "detailed",
            "textVerbosity": "medium",
            "include": [
              "reasoning.encrypted_content"
            ],
            "store": false
          }
        },
        "gpt-5.1-codex-mini-medium": {
          "name": "GPT 5.1 Codex Mini Medium (OAuth)",
          "limit": {
            "context": 272000,
            "output": 128000
          },
          "options": {
            "reasoningEffort": "medium",
            "reasoningSummary": "auto",
            "textVerbosity": "medium",
            "include": [
              "reasoning.encrypted_content"
            ],
            "store": false
          }
        },
        "gpt-5.1-codex-mini-high": {
          "name": "GPT 5.1 Codex Mini High (OAuth)",
          "limit": {
            "context": 272000,
            "output": 128000
          },
          "options": {
            "reasoningEffort": "high",
            "reasoningSummary": "detailed",
            "textVerbosity": "medium",
            "include": [
              "reasoning.encrypted_content"
            ],
            "store": false
          }
        },
        "gpt-5.1-low": {
          "name": "GPT 5.1 Low (OAuth)",
          "limit": {
            "context": 272000,
            "output": 128000
          },
          "options": {
            "reasoningEffort": "low",
            "reasoningSummary": "auto",
            "textVerbosity": "low",
            "include": [
              "reasoning.encrypted_content"
            ],
            "store": false
          }
        },
        "gpt-5.1-medium": {
          "name": "GPT 5.1 Medium (OAuth)",
          "limit": {
            "context": 272000,
            "output": 128000
          },
          "options": {
            "reasoningEffort": "medium",
            "reasoningSummary": "auto",
            "textVerbosity": "medium",
            "include": [
              "reasoning.encrypted_content"
            ],
            "store": false
          }
        },
        "gpt-5.1-high": {
          "name": "GPT 5.1 High (OAuth)",
          "limit": {
            "context": 272000,
            "output": 128000
          },
          "options": {
            "reasoningEffort": "high",
            "reasoningSummary": "detailed",
            "textVerbosity": "high",
            "include": [
              "reasoning.encrypted_content"
            ],
            "store": false
          }
        }
      }
    },
    "custom": {
      "name": "Custom OpenAI Provider",
      "options": {
        "baseURL": "OPENCODE_PROVIDER_URL_VALUE",
        "apiKey": "OPENCODE_API_KEY_VALUE"
      }
    }
  },
  "default_provider": "custom"
}
JSONCFG
      sed -i "s|OPENCODE_PROVIDER_URL_VALUE|$${OPENCODE_PROVIDER_URL}|g" /home/coder/.opencode/opencode.json
      sed -i "s|OPENCODE_API_KEY_VALUE|$${OPENCODE_API_KEY}|g" /home/coder/.opencode/opencode.json
      ln -sf /home/coder/.opencode/opencode.json /home/coder/.opencode/config.json || true
      chown -R "$USER:$USER" /home/coder/.opencode || true
    fi

    # Wrapper ya no necesario
  EOT

  env = {
    GIT_AUTHOR_NAME       = coalesce(data.coder_workspace_owner.me.full_name, data.coder_workspace_owner.me.name)
    GIT_AUTHOR_EMAIL      = data.coder_workspace_owner.me.email
    GIT_COMMITTER_NAME    = coalesce(data.coder_workspace_owner.me.full_name, data.coder_workspace_owner.me.name)
    GIT_COMMITTER_EMAIL   = data.coder_workspace_owner.me.email
    HOME                  = "/home/coder"
    OPENCODE_PROVIDER_URL = data.coder_parameter.opencode_provider_url.value
    OPENCODE_API_KEY      = data.coder_parameter.opencode_api_key.value
    CODER_USER_EMAIL      = data.coder_workspace_owner.me.email
    VSCODE_EXTENSIONS     = join(" ", local.vscode_extensions)
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
}

# Módulos
module "code-server" {
  count      = data.coder_workspace.me.start_count
  source     = "registry.coder.com/coder/code-server/coder"
  version    = "~> 1.0"
  agent_id   = coder_agent.main.id
  extensions = local.vscode_extensions
  order      = 1
}

module "kasmvnc" {
  count               = data.coder_workspace.me.start_count
  source              = "registry.coder.com/coder/kasmvnc/coder"
  version             = "1.2.6"
  agent_id            = coder_agent.main.id
  desktop_environment = "kde"
  subdomain           = true
}

module "git-clone" {
  count       = data.coder_parameter.git_repo_url.value != "" ? data.coder_workspace.me.start_count : 0
  source      = "registry.coder.com/coder/git-clone/coder"
  version     = "1.2.2"
  agent_id    = coder_agent.main.id
  url         = data.coder_parameter.git_repo_url.value
  base_dir    = "~/projects"
}

module "coder-login" {
  count    = data.coder_workspace.me.start_count
  source   = "registry.coder.com/coder/coder-login/coder"
  version  = "1.1.1"
  agent_id = coder_agent.main.id
}

module "filebrowser" {
  count    = data.coder_workspace.me.start_count
  source   = "registry.coder.com/coder/filebrowser/coder"
  version  = "1.1.3"
  agent_id = coder_agent.main.id
  folder   = "/home/coder/project"
}

module "opencode" {
  source   = "registry.coder.com/coder-labs/opencode/coder"
  version  = "0.1.1"
  agent_id = coder_agent.main.id
  workdir  = "/home/coder/"
}

# HOME PERSISTENTE
resource "docker_volume" "home_volume" {
  count = local.home_host_path == "" && local.home_volume_existing == "" ? 1 : 0
  name  = local.home_volume_resolved

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

# CONTENEDOR PRINCIPAL DEL WORKSPACE
resource "docker_container" "workspace" {
  image = local.workspace_image

  name     = "coder-${data.coder_workspace_owner.me.name}-${lower(data.coder_workspace.me.name)}"
  hostname = data.coder_workspace.me.name

  user = local.home_host_uid != "" ? local.home_host_uid : "coder"

  entrypoint = [
    "sh",
    "-c",
    replace(coder_agent.main.init_script, "/localhost|127\\.0\\.0\\.1/", "host.docker.internal")
  ]

  env = [
    "CODER_AGENT_TOKEN=${coder_agent.main.token}",
    "TZ=Europe/Madrid",
    "NVIDIA_VISIBLE_DEVICES=${local.enable_gpu ? "all" : ""}",
    "NVIDIA_DRIVER_CAPABILITIES=compute,utility,graphics,video"
  ]

  shm_size = 2 * 1024 * 1024 * 1024
  # Permitir FUSE/SSHFS y montajes remotos
  capabilities {
    add = ["SYS_ADMIN"]
  }
  devices {
    host_path          = "/dev/fuse"
    container_path     = "/dev/fuse"
    permissions        = "rwm"
  }

  security_opts = ["apparmor:unconfined"]

  dynamic "volumes" {
    for_each = local.home_host_path != "" ? [1] : []
    content {
      container_path = "/home/coder"
      host_path      = local.home_host_path
    }
  }

  dynamic "volumes" {
    for_each = local.home_host_path == "" ? [local.home_volume_resolved] : []
    content {
      container_path = "/home/coder"
      volume_name    = volumes.value
    }
  }

  dynamic "volumes" {
    for_each = local.host_data_path != "" ? [1] : []
    content {
      container_path = "/home/coder/host-data"
      host_path      = local.host_data_path
    }
  }

  host {
    host = "host.docker.internal"
    ip   = "host-gateway"
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
  labels {
    label = "com.centurylinklabs.watchtower.enable"
    value = "true"
  }
  labels {
    label = "com.centurylinklabs.watchtower.scope"
    value = "coder-workspaces"
  }
}
