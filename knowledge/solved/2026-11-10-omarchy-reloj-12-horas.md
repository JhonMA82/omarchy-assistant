---
component: omarchy
scope: machines
machine: omarchy
tags:
  - chezmoi
  - omarchy-shell
  - clock
  - shell.json
---

# Reloj del bar de Omarchy en formato de 12 horas

## Problema

El reloj del bar mostrado por `omarchy.clock` usaba formato de 24 horas (`martes 14:32`). Se quería el formato de 12 horas con AM/PM (`martes 2:32 P.M.`).

## Causa

El formato del reloj es configuración de usuario del shell y vive en `~/.config/omarchy/shell.json`, dentro del widget `omarchy.clock` del layout del bar:

```json
{
  "id": "omarchy.clock",
  "format": "dddd HH:mm",
  "formatAlt": "d MMMM 'W'ww yyyy",
  "verticalFormat": "HH\n—\nmm"
}
```

`format` y `verticalFormat` se interpretan con los tokens de fecha/hora de Qt (`Date.toLocaleString`): `HH` es hora en 24 h, mientras que `h`/`hh` con `AP` produce hora de 12 h con AM/PM. El valor por defecto de Omarchy es `dddd HH:mm`.

El archivo ya estaba capturado en la capa de la máquina como `private_shell.json` (ver `knowledge/solved/2026-10-15-omarchy-idle-screensaver-10-min.md`), así que el cambio va ahí y no a una capa compartida.

## Solución validada

Usar los presets de 12 horas que Omarchy ya define en `shell/plugins/panels/clock/Model.js` (`CLOCK_FORMATS` / `VERTICAL_CLOCK_FORMATS`), para que el formato sea el gemelo exacto del preset 24 h y siga funcionando el ciclo por clic derecho:

```json
{
  "id": "omarchy.clock",
  "format": "dddd h:mm AP",
  "formatAlt": "d MMMM 'W'ww yyyy",
  "verticalFormat": "h\n—\nmm\nAP"
}
```

`formatAlt` no cambia: es el alterno de solo fecha. No hace falta reiniciar el shell; `shell.json` se vigila con `FileView` (`watchChanges: true`) y se recarga al guardar. En la práctica tampoco hace falta `omarchy restart shell`.

## Scope

`machines`: el formato del reloj es preferencia de esta estación y el archivo está capturado completo en `home/profiles/machines/omarchy/`. No debe promoverse a `home/omarchy/` sin decidir explícitamente que el formato de 12 h aplica a todos los equipos.

## Archivos afectados

- `home/profiles/machines/omarchy/dot_config/omarchy/private_shell.json`
- `knowledge/solved/2026-11-10-omarchy-reloj-12-horas.md` (nuevo)

## Verificación

- `python3 -m json.tool ~/.config/omarchy/shell.json` → JSON válido.
- `chezmoi --source "<repo>/home/profiles/machines/omarchy" status` y `diff` → sin salida (capa aplicada e idempotente).
- `scripts/verify` → `State: HEALTHY`, con WARN esperados de kitty sin validador nativo y configuración local sin trackear.
- Comprobación visual del bar (`grim`): `martes 12:02 P.M.`.
- Validadores `fish -n`, `starship print-config`, `ghostty +show-config` no aplican a este cambio.

## Rollback

Volver a los valores de 24 h en `private_shell.json` (`"format": "dddd HH:mm"` y `"verticalFormat": "HH\n—\nmm"`) y aplicar:

```bash
chezmoi apply --source "<repo>/home/profiles/machines/omarchy"
```

Alternativa: `git revert <commit>` y volver a aplicar la capa. Sin chezmoi, editar los tres campos a mano en `~/.config/omarchy/shell.json` y guardar. Ojo: `omarchy refresh shell` restaura los defaults (24 h) y descarta esta capa.

## Git

- `feat(omarchy): reloj del bar en formato de 12 horas`
