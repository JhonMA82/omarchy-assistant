# Changelog

Todas las versiones notables de este proyecto se documentan en este archivo.
El formato sigue [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) y
el versionado sigue [SemVer](https://semver.org/lang/es/).

## [Unreleased]

Sin cambios aún.

## [0.2.1] - 2026-08-15

Integridad de chezmoi: verificación por estado efectivo final por capa y consolidación fail-closed cuando chezmoi no está disponible.

### Corregido

- `scripts/verify`: la verificación de chezmoi usa el estado efectivo final — cada target lo valida solo la capa más alta que lo administra, eliminando los falsos FAIL por la superposición intencional de `dot_config/omarchy-assistant/profile`. Un error real de chezmoi (source inexistente, plantilla rota) ahora es FAIL con el error, nunca un PASS silencioso.
- `/solved` (`.opencode/commands/solved.md`): guard fail-closed — si chezmoi no está instalado, detiene la consolidación sin known-good, commit ni push.

[Unreleased]: https://github.com/JhonMA82/omarchy-assistant/compare/v0.2.1...HEAD
[0.2.1]: https://github.com/JhonMA82/omarchy-assistant/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/JhonMA82/omarchy-assistant/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/JhonMA82/omarchy-assistant/releases/tag/v0.1.0
