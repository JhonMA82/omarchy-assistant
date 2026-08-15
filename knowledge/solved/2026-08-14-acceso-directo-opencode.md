# Acceso directo de escritorio para abrir el repositorio en opencode con Ghostty

## Problema

No existía una forma rápida de abrir el repositorio Omarchy Assistant en opencode dentro de una ventana de Ghostty: había que abrir una terminal, navegar hasta el directorio y ejecutar `opencode`.

## Causa

No se había creado un acceso directo de escritorio; el launcher/menú de Omarchy solo mostraba las aplicaciones con archivos `.desktop` en `~/.local/share/applications/`.

## Solución validada

Crear `~/.local/share/applications/Omarchy Assistant.desktop` con `Exec=ghostty --working-directory=/home/juan/Dev/omarchy-assistant -e opencode` e icono `com.mitchellh.ghostty`. El acceso directo abre una ventana de Ghostty en el directorio del repositorio y lanza opencode. La combinación `ghostty --working-directory=<dir> -e <cmd>` se validó manualmente ejecutando el comando y comprobando que la ventana se abría y ejecutaba el proceso.

## Scope

machines/omarchy (específico de esta máquina: el path del repositorio `/home/juan/Dev/omarchy-assistant` es particular de este equipo). Se crea la capa `home/profiles/machines/omarchy/` por ser el hostname actual.

## Archivos afectados

- `home/profiles/machines/omarchy/dot_config/omarchy-assistant/class` (nuevo, clase `desktop`)
- `home/profiles/machines/omarchy/dot_config/omarchy-assistant/profile` (nuevo, perfil `common+omarchy+desktop+omarchy`)
- `home/profiles/machines/omarchy/dot_local/share/applications/Omarchy Assistant.desktop` (nuevo)
- `packages/desktop.txt` (se registra `ghostty`, dependencia del acceso directo)

## Verificación

- `desktop-file-validate ~/.local/share/applications/Omarchy Assistant.desktop` sin errores (exit 0).
- Lanzamiento manual: `ghostty --working-directory=/home/juan/Dev/omarchy-assistant -e sleep 10` abrió una ventana de Ghostty y ejecutó el comando.
- `scripts/verify --profile omarchy --class desktop` → State: HEALTHY (con `[WARN] chezmoi no instalado`, que no degrada).

## Rollback

- `git checkout HEAD -- home/profiles/machines/omarchy packages/desktop.txt` y eliminar `~/.local/share/applications/Omarchy Assistant.desktop`.
- Si la capa se aplicó con chezmoi: `chezmoi --source <repo>/home/profiles/machines/omarchy` remove sobre el archivo o editar/eliminar la capa y reaplicar.

## Git

- Commit: `feat(machines): add desktop shortcut for opencode in ghostty` — `<hash>`.
