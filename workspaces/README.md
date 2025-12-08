# Workspaces Coder

Guía rápida para elegir template y rellenar los parámetros al crear un workspace en Coder.

## Qué template usar
- `Developer` (DinD): desarrollo general con Docker in Docker, puertos opcionales y GPU si el nodo la expone.
- `DeveloperAdvancedHost`: acceso directo a Docker y red del host. Úsalo solo si necesitas diagnosticar o tocar el host.
- `Designer`: entorno gráfico KDE/KasmVNC con suite de diseño 2D/3D, CAD y EDA. GPU opcional.
- `DeveloperBasic`: sin escritorio; code-server + Docker in Docker ligeros.

## Creación rápida en Coder
1) Elige template y revisa su README (`workspaces/<Template>/README.md`) para ver qué incluye.
2) Rellena los parámetros clave:
   - **GPU**: actívalo solo si el nodo tiene GPU configurada.
   - **Puertos** (`Developer`): decide si expones puertos al host y el rango.
   - **Home**: puedes montar `/home/coder` desde el host o dejar el volumen Docker por defecto. Ajusta el UID si la carpeta host no es 1000.
   - **Datos extra**: `~/host-data` permite montar una carpeta puntual del host. En `Developer`, también puedes nombrar/reutilizar el volumen de `/var/lib/docker`.
   - **OpenCode**: rellena URL/API key solo si quieres configurar un proveedor OpenAI-compatible de inicio.
   - **Clonado inicial**: añade `Repositorio Git` para clonar en `~/projects` al primer arranque.
3) Crea el workspace. Usa KasmVNC para escritorio (RDP solo aplica a plantillas Windows).

## Documentación de cada template
- `workspaces/Developer/README.md`
- `workspaces/DeveloperAdvancedHost/README.md`
- `workspaces/Designer/README.md`
- `workspaces/DeveloperBasic/README.md`

Para publicar cambios tras editarlos, consulta `README.md` y `AGENTS.md`.
