---
component: omarchy
scope: machines
machine: omarchy
tags:
  - chezmoi
  - idle
  - screensaver
  - omarchy-shell
---

# Tiempo del protector de pantalla y del bloqueo en Omarchy

## Problema

El protector de pantalla se activaba a los 2.5 min de inactividad, demasiado corto para la estación. El objetivo era 10 min.

## Causa

Omarchy guarda los tiempos de inactividad en `~/.config/omarchy/shell.json`, en el bloque `idle`, en segundos. Los defaults empaquetados (`/usr/share/omarchy/config/omarchy/shell.json`) traían `screensaver: 150` y `lock: 300`.

Los dos valores son independientes y el shell no aplica el de mayor precedence: en `/usr/share/omarchy/shell/plugins/services/idle/Service.qml` el primer disparo usa

```text
firstIdleTimeoutSeconds    = min(screensaver, lock)
screensaverDelaySeconds    = max(0, screensaver - lock)
```

Es decir, el bloqueo se arma primero y el protector se aplica como retardo posterior. Subir solo `screensaver` a 600 con `lock` en 300 habría hecho que la pantalla **se bloqueara a los 5 min y se apagara a los 10**, al revés de lo esperado.

## Solución validada

Poner ambos valores a 600 s (10 min) en `~/.config/omarchy/shell.json`:

```json
"idle": {
  "lock": 600,
  "screensaver": 600
}
```

No hace falta reiniciar el shell. `shell.qml` declara el archivo con vigilancia activa:

```qml
FileView {
  id: userConfigFile
  path: shell.userConfigPath          // ~/.config/omarchy/shell.json
  watchChanges: true
  onFileChanged: reload()
}
```

Al guardar, `reload()` dispara `applyShellConfig()` y el servicio de inactividad ya usa los valores nuevos.

Como `~/.config/omarchy/` no estaba administrado por chezmoi, el archivo se capturó en la capa de la máquina con `chezmoi add`. Chezmoi aplica el prefijo `private_` cuando el archivo de destino tiene modo `600`, de ahí `private_shell.json`.

Advertencia heredada de `omarchy refresh hyprland` (ver `knowledge/solved/2026-09-28-omarchy-refresh-hyprland-resetea-monitores.md`): `omarchy refresh shell` copia los defaults sobre `~/.config/omarchy/shell.json` y descarta esta capa. Restaurar con `chezmoi apply --force --source "<repo>/home/profiles/machines/omarchy"`.

## Scope

`machines`: el bloque `idle` junto al layout de barra es una preferencia de estación, no una política transversal. La captura es de archivo completo, así que la capa incluye también el layout de barra de esta máquina y no debe promoverse a `home/omarchy/` sin decidirlo explícitamente.

## Archivos afectados

- `home/profiles/machines/omarchy/dot_config/omarchy/private_shell.json` (nuevo)
- `knowledge/solved/2026-10-15-omarchy-idle-screensaver-10-min.md` (nuevo)

## Verificación

- `python3 -m json.tool ~/.config/omarchy/shell.json` → JSON válido; `idle` = `{'lock': 600, 'screensaver': 600}`.
- `chezmoi --source "<repo>/home/profiles/machines/omarchy" status` y `diff` → sin salida.
- `scripts/verify` → la capa de la máquina no reporta diferencias.
- `journalctl --user | grep idle-cycle-start` → cada ciclo de inactividad registra `screensaver=<s> lock=<s>`; sirve para confirmar los valores que el shell tiene cargados en memoria.
- Validación manual del usuario.

Pendiente y ajeno a esta solución: `scripts/verify` marca FAIL en la capa `common` por `.config/fish/config.fish` y `.config/kitty/kitty.conf`, un drift heredado de sesiones anteriores.

## Rollback

```bash
chezmoi apply --force --source "<repo>/home/profiles/machines/omarchy"
```

Sin chezmoi, editar `idle.screensaver` e `idle.lock` a mano en `~/.config/omarchy/shell.json` y guardar.

## Git

- `feat(omarchy): idle screensaver y lock a 10 min`