# Changelog

Todas las versiones notables de este proyecto se documentan en este archivo.
El formato sigue [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) y
el versionado sigue [SemVer](https://semver.org/lang/es/).

## [Unreleased]

Sin cambios aún.

## [0.2.0] - 2026-08-14

Optimización de contexto v0.2: disciplina de contexto para reducir lecturas y tokens, y primera consolidación de soluciones (Fish y acceso directo).

### Añadido

- Configuración de arranque de Fish compatible con Omarchy v4 en `home/common/dot_config/fish/config.fish`.
- Acceso directo de escritorio que abre OpenCode en Ghostty dentro del repositorio, en `home/profiles/desktop/`.
- Entradas de knowledge: `2026-08-14-fish-shell-default.md` y `2026-08-14-acceso-directo-opencode.md`.
- Paquetes `fish` y `ghostty` registrados en los manifiestos (`packages/common.txt`, `packages/desktop.txt`).

### Cambiado

- `AGENTS.md`: nueva sección «Contexto bajo demanda» (no precargar el repositorio, search-before-read, `knowledge/` lazy, `bootstrap.sh` y scripts de infraestructura solo si la tarea los afecta, routing por componente y niveles de contexto).
- `/solved` orientado al delta de la sesión: búsqueda de duplicados con `rg` antes de crear entradas y frontmatter ligero (`component`, `scope`, `machine`, `tags`, `commit`).
- `README.md` documenta la disciplina de contexto.
- Especificación v0.1 reemplazada por `OPENCODE_OMARCHY_ASSISTANT_V0.2_CONTEXT_OPTIMIZATION.md`.

[Unreleased]: https://github.com/JhonMA82/omarchy-assistant/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/JhonMA82/omarchy-assistant/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/JhonMA82/omarchy-assistant/releases/tag/v0.1.0
