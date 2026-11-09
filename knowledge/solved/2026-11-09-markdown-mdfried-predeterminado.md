---
component: desktop
scope: machines/omarchy
machine: omarchy
tags:
  - markdown
  - mime
  - mdfried
  - xdg
commit: 3c1b056
---

# Archivos Markdown abiertos con mdfried por defecto

## Problema

Al abrir cualquier archivo `.md` desde Nautilus o `gio open` se lanzaba Omawrite en lugar de mdfried, aunque mdfried ya estaba instalado.

## Causa

`text/markdown` estaba asociado a `omawrite.desktop` en `~/.config/mimeapps.list` y no existía ninguna entrada de escritorio para mdfried, así que tampoco aparecía como aplicación registrada para ese tipo MIME.

## Solución validada

1. Crear `~/.local/share/applications/mdfried.desktop` con `Terminal=true`, `Exec=mdfried %f` y `MimeType=text/markdown;`.
2. Registrar la entrada como predeterminada:

   ```bash
   xdg-mime default mdfried.desktop text/markdown text/x-markdown
   update-desktop-database ~/.local/share/applications
   ```

Con `Terminal=true`, GIO lanza el comando mediante `xdg-terminal-exec`, que respeta el terminal preferido de `~/.config/xdg-terminals.list` (kitty en este equipo).

Dependencia: `mdfried` 0.22.8 instalado con `cargo install mdfried`. El paquete oficial existe en `extra` (`pacman -S mdfried`), pero solo instala `/usr/bin/mdfried`, sin archivo `.desktop`, por lo que la entrada personalizada sigue siendo necesaria. No se registró en `packages/` porque la instalación actual no proviene de pacman y `scripts/verify` marcaría el paquete como faltante; si se migra al paquete oficial, agregar `mdfried` a `packages/machines/omarchy.txt`.

## Scope

`machines/omarchy` (clase `desktop`). La asociación depende de las aplicaciones instaladas en esta máquina concreta.

## Archivos afectados

- `home/profiles/machines/omarchy/dot_local/share/applications/mdfried.desktop` (nuevo)
- `home/profiles/machines/omarchy/dot_config/mimeapps.list` (nuevo en chezmoi; antes no estaba administrado)

## Verificación

- `desktop-file-validate` sobre el `.desktop` → exit 0.
- `xdg-mime query default text/markdown` y `text/x-markdown` → `mdfried.desktop`.
- `gio mime text/markdown` → aplicación predeterminada `mdfried.desktop`.
- Validación manual del usuario: abrir un `.md` desde Nautilus y con `gio open` lanza mdfried dentro de kitty.
- `scripts/verify` → `State: DEGRADED` únicamente por la diferencia preexistente y dinámica de `.config/omadeck/config.toml` (icono de la tecla Swap según el monitor enfocado), ajena a esta solución. El resto de los chequeos: `PASS`.

## Rollback

```bash
xdg-mime default omawrite.desktop text/markdown text/x-markdown
git checkout HEAD~1 -- home/profiles/machines/omarchy/dot_config/mimeapps.list \
  home/profiles/machines/omarchy/dot_local/share/applications/mdfried.desktop
chezmoi apply --source home/profiles/machines/omarchy -- ~/.config/mimeapps.list
rm ~/.local/share/applications/mdfried.desktop
```

## Git

- Commit de la solución: `3c1b056` — `fix(desktop): abre archivos Markdown con mdfried`.
- Patrón relacionado: `knowledge/solved/2026-10-27-acceso-directo-thinkrail.md` (entrada `.desktop` en `~/.local/share/applications`).
