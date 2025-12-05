# Instrucciones para Claude Code

## Contexto del proyecto

Este repositorio contiene imágenes Docker y templates de workspaces de Coder para Makers/Hackers de MakeSpace Madrid.

**Lee primero `AGENTS.md`** para entender la arquitectura completa: imágenes disponibles, templates, flujo de publicación y notas operativas.

## Principios de trabajo

1. **Lee antes de modificar**: Siempre lee los archivos completos (Dockerfiles, templates, workflows) antes de proponer cambios
2. **Seguridad**: Evita vulnerabilidades en Dockerfiles y templates
3. **Simplicidad**: No sobre-ingenierices. Solo lo necesario
4. **Testing local**: Verifica builds y templates localmente cuando sea posible

## Estructura del proyecto

```
Docker-Images/
  Developer/Dockerfile    # Imagen para desarrollo
  Designer/Dockerfile     # Imagen para diseño/CAD/electrónica
.coder/templates/         # Templates de Coder
.github/workflows/        # CI/CD (build y push a GHCR)
AGENTS.md                 # Documentación principal (léela)
AGENTS.private.md         # Instrucciones privadas (no versionado)
```

## Flujo de trabajo

1. Cambios se hacen en branches
2. Merge a `main` dispara build automático en GitHub Actions
3. Imágenes se publican en `ghcr.io/makespacemadrid/coder-mks-{developer,design}:latest`
4. Templates se actualizan con `coder templates push` (solo afecta nuevos workspaces)

## Notas importantes

- **No versiones datos sensibles**: URLs internas, IPs, credenciales van en `AGENTS.private.md` (gitignored)
- **Watchtower**: Las imágenes llevan labels para auto-actualización
- **Agent fallback**: Existe bootstrap local para entornos con red restringida
- **DeveloperAdvancedHost**: Template DANGER con acceso host, usar con precaución

## Comandos útiles

```bash
# Build local
docker build -f Docker-Images/Developer/Dockerfile -t test-dev .
docker build -f Docker-Images/Designer/Dockerfile -t test-design .

# Push templates
coder templates push Developer
coder templates push Designer
```

Consulta `AGENTS.md` para más detalles.
