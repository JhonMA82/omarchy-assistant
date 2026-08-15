# Changelog

Todas las versiones notables de este proyecto se documentan en este archivo.
El formato sigue [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) y
el versionado sigue [SemVer](https://semver.org/lang/es/).

## [Unreleased]

Sin cambios aún.

## [0.1.0] - 2026-08-14

Primera versión del proyecto: Omarchy Assistant v0.1, alineado al baseline
Omarchy v4 (Quattro).

### Añadido

- Estructura mínima del repositorio definida en `OMARCHY_ASSISTANT_INITIAL_SPEC.md`.
- Capas de chezmoi en orden canónico (common → omarchy → clase → máquina), con identificación por hostname y override vía `OMARCHY_PROFILE` / `--profile`.
- `bootstrap.sh` idempotente: verifica Omarchy, instala chezmoi, resuelve perfil y clase, instala paquetes declarados, aplica las capas y ejecuta `scripts/verify`.
- `scripts/verify` (solo lectura), `scripts/doctor` (diagnóstico) y `scripts/rollback` (retroceso por componente apoyado en Git).
- Comando `/solved` de OpenCode para consolidar soluciones validadas.
- Skills `omarchy-maintainer` y `workstation-state` alineadas a Omarchy v4 Quattro (Quickshell reemplaza a Waybar y Walker).
- Knowledge base (`knowledge/solved/`) con plantilla y ejemplo de referencia.
- Manifiestos de paquetes (`packages/`) con repos oficiales de pacman (AUR fuera del alcance de v0.1).
- `README.md`, `AGENTS.md` y `.gitignore`.

[Unreleased]: https://github.com/JhonMA82/omarchy-assistant/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/JhonMA82/omarchy-assistant/releases/tag/v0.1.0
