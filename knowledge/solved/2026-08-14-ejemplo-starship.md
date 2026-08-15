---
component: starship
scope: common
machine: all
tags:
  - shell
  - prompt
  - performance
commit: "<hash>"
---

> Ejemplo de referencia: muestra el formato de una entrada de `knowledge/solved/`; no corresponde a una solución real.

# Ejemplo: Starship lento por un comando personalizado

## Problema

El prompt tardaba aproximadamente dos segundos en aparecer en cada terminal nueva con Starship activo.

## Causa

Un módulo `custom` en `~/.config/starship.toml` ejecutaba un proceso externo en cada renderizado del prompt. Como Starship renderiza una vez por línea, ese proceso encarecía cada render.

## Solución validada

Eliminar el módulo `custom` lento y conservar solo módulos integrados de Starship. El prompt volvió a ser inmediato y `starship print-config` validó la configuración sin errores.

## Scope

common (afecta a todos los equipos).

## Archivos afectados

- `home/common/dot_config/starship.toml`

## Verificación

- `STARSHIP_CONFIG=home/common/dot_config/starship.toml starship print-config` sin errores.
- `scripts/verify` → `[PASS] starship`.
- Prompt inmediato en una terminal nueva.

## Rollback

- `scripts/rollback starship` restaura la versión registrada anterior.
- Alternativa manual: `git checkout HEAD -- home/common/dot_config/starship.toml` y reaplicar las capas de chezmoi en orden.

## Git

- Commit: `fix(starship): remove slow custom command` — `<hash>`.
