# coder-mks-developer

Imagen de Coder Desktop extendida con utilidades de desarrollo, Docker y CLI para IA (OpenAI/Codex, Claude y Gemini).

## Build

```bash
docker build -t coder-mks-developer Docker-Images/Developer
```

También se publica automáticamente en GHCR al hacer push a `main`/`master`: `ghcr.io/makespacemadrid/coder-mks-developer:latest`.

## Herramientas incluidas

- Docker Engine + Docker Compose (desde repositorio oficial de Docker).
- CLI `codex-cli` (usa OpenAI Chat, requiere `OPENAI_API_KEY`, modelo por defecto `gpt-4o-mini`, configurable con `CODEX_MODEL`).
- CLI `claude-cli` (requiere `ANTHROPIC_API_KEY`, modelo por defecto `claude-3-5-sonnet-20240620`, configurable con `CLAUDE_MODEL`).
- CLI `gemini-cli` (requiere `GEMINI_API_KEY` o `GOOGLE_API_KEY`, modelo por defecto `gemini-1.5-flash`, configurable con `GEMINI_MODEL`). Alias: `gemini`.

Ejemplos rápidos:

```bash
# Codex (OpenAI)
OPENAI_API_KEY=... codex-cli "Di hola"

# Claude
ANTHROPIC_API_KEY=... claude-cli "Hola"

# Gemini
GEMINI_API_KEY=... gemini-cli "Hola"
```

## Sugerencias opcionales

- Añadir `gcloud` si se necesitan otros servicios de Google Cloud.
- Incluir `kubectl` y `helm` para despliegues.
- Instalar `ollama` si quieres modelos locales.
