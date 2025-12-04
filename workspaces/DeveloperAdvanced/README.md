---
display_name: MakeSpace Dev Workspace
description: Entorno de desarrollo completo basado en Docker
icon: ../../assets/icons/dev.svg
maintainer_github: makespacemadrid
tags: [docker, workspace, makespace]
---

# MakeSpace Developer avanzado

Este template proporciona un entorno de desarrollo completo, corriendo dentro de un contenedor Docker pero con acceso directo al **Docker del host** y a las GPUs.
Este workspace mal usado puede joder cosas en el host, si no necesitas acceso directo a las gpus usa el contenedor de Docker in Docker (dnd)

El objetivo es que puedas levantar un workspace reproducible, aislado y fácil de resetear sin perder tus archivos, con escritorio gráfico, editor de código y herramientas modernas de desarrollo.

Incluye:

- Escritorio **XFCE** vía **KasmVNC**
- **code-server** (VS Code en el navegador)
- **Cursor**, **JupyterLab**, **Tmux**
- **Filebrowser** (gestor de archivos web)
- **Docker CLI + docker-compose-plugin**
- **Node.js 20** y **Codex CLI**
- Acceso directo al Docker del host (`/var/run/docker.sock`)
- Home persistente con un volumen dedicado
- Activación opcional de puertos hacia el host

Este workspace está pensado para proyectos de software, infra, automatización, electrónica y experimentación en la nube que hacemos en el espacio.

---

## Requisitos en MakeSpace

El servidor que ejecuta Coder en MakeSpace:

- Tiene Docker instalado y funcionando
- Expone el socket de Docker al template  
- Permite asignar el mismo GID del grupo `docker` del host al contenedor  
  (actualmente GID `995`)

No hace falta añadir al usuario `coder` al grupo docker del sistema.  
El template lo gestiona usando:

```hcl
group_add = ["995"]
Si alguna vez se cambia este GID en el host, habrá que actualizar el template.

Persistencia
Cada workspace tiene un volumen Docker con tu home:

arduino
Copiar código
/home/coder
Todo lo que guardes ahí es persistente:

Código

Configuración (git, SSH, dotfiles…)

Notebooks y scripts

Proyectos personales

Herramientas instaladas por npm/pip dentro de $HOME

Todo lo demás (paquetes del sistema fuera de /home) se pierde al reiniciar el workspace.
Si necesitas herramientas adicionales, pide que se añadan al startup script o al Dockerfile base.

Acceso a Docker del host
El workspace monta el socket:

arduino
Copiar código
/var/run/docker.sock
Esto permite:

Ejecutar docker ps

Levantar o detener contenedores del host

Ejecutar docker compose up

Hacer builds

Usar GPUs (si el host las expone)

Se debe usar con responsabilidad:
si rompes un contenedor del host principal, rompes servicios del espacio.

Escritorio gráfico
El workspace incluye un escritorio XFCE vía KasmVNC, accesible desde la consola del workspace.

Útil para:

Navegar la web

Trabajar con herramientas GUI ligeras

Simulaciones

Testing visual

Apps gráficas sin necesidad de X11 local

Opcional: exposición de puertos al host
Por defecto, los puertos no se exponen al host para evitar conflictos entre varios usuarios.

Puedes activar un checkbox al crear el workspace:

Expose ports: true/false

port_range_start: número

port_range_end: número

Esto sirve para proyectos web, APIs o microservicios que quieras acceder desde la LAN del espacio.

Edición y personalización
Dotfiles
Si quieres personalizar tu entorno automáticamente (zsh, tmux, neovim, etc.), puedes usar:

https://coder.com/docs/dotfiles

Paquetes de sistema
Si necesitas algo extra, pídelo para añadirlo en el mismo startup_script.

Imagen base personalizada
Podemos crear una imagen Docker propia del MakeSpace para:

Añadir toolchains pesados (Rust, Go, ARM, ESP-IDF…)

Añadir toolchains CNC/3D printing

Incorporar toolchains electrónicos (KiCad, PlatformIO…)

Seguridad y buenas prácticas
No ejecutes contenedores pesados en el nodo de producción sin avisar.

No levantes servicios accesibles públicamente sin configurar NPM o traefik.

Mantén tu workspace limpio: borra contenedores que ya no uses.

Evita instalar software del sistema dentro del contenedor: no persistirá.

Para qué se usa típicamente en MakeSpace
Programación general (Python, JS, TS, Go…)

Infra y DevOps (Docker Compose, Ansible, Coder, Terraform…)

Backend y APIs

Automatización del Makerspace (n8n, Home Assistant, Node-RED…)

Testing en entornos aislados

Prototipos que necesitan un entorno Linux limpio

Cómo actualizar la plantilla
Si editamos la imagen base o el template:

sh
Copiar código
coder templates push
Los cambios afectarán a nuevos workspaces, pero no a los ya existentes.

Este workspace está pensado para que cualquier socio pueda tener una “máquina virtual” de desarrollo lista para usar en segundos, sin instalar nada en su ordenador personal. Si quieres añadir herramientas, optimizaciones o integraciones con otros sistemas del MakeSpace, dímelo y lo incorporamos.
