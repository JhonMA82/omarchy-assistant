# Fish como shell por defecto con init de Omarchy

## Problema

Al instalar fish y cambiarlo a shell por defecto, cada terminal mostraba el mensaje de bienvenida ("Welcome to fish, the friendly interactive shell") y el prompt cambiaba al plano por defecto de fish en lugar del prompt de starship que Omarchy usa en bash.

## Causa

Omarchy v4 configura su shell (bash) mediante `/usr/share/omarchy/default/bash/init` (starship, zoxide, mise, fzf). Un fish instalado de cero arranca con su config por defecto: `fish_greeting` sin definir (por eso el mensaje de bienvenida) y sin init de starship. Además, las terminales heredan el shell de la sesión gráfica: cambiar `/etc/passwd` con `chsh` solo surte efecto tras reiniciar la sesión.

## Solución validada

- `chsh -s /usr/bin/fish` y reinicio de la sesión de Hyprland (`hyprctl dispatch exit`) para que las terminales arranquen con fish.
- Crear `~/.config/fish/config.fish` que desactiva el mensaje de bienvenida (`set -g fish_greeting ""`) e inicializa starship (`starship init fish | source`), replicando el prompt de bash.

## Scope

common: la configuración de fish es genérica y válida para todos los equipos Omarchy (se alinea con `home/common/dot_config/fish/conf.d/omarchy-assistant.fish` ya existente). El cambio de shell del sistema (`chsh`) queda fuera del repositorio.

## Archivos afectados

- `home/common/dot_config/fish/config.fish` (nuevo)
- `packages/common.txt` (se registra `fish`)

## Verificación

- `fish -n ~/.config/fish/config.fish` sin errores.
- En sesión interactiva (`script -qec "fish -i ..."`): `$fish_greeting` vacío y `fish_prompt` muestra el prompt de starship.
- Validación manual del usuario en una terminal nueva: sin mensaje de bienvenida y con el prompt de starship.
- `scripts/verify --profile omarchy --class desktop` → State: HEALTHY (con `[WARN] chezmoi no instalado`, que no degrada).

## Rollback

- `chsh -s /usr/bin/bash` y eliminar `~/.config/fish/config.fish`.
- En el repo: `git checkout HEAD -- home/common/dot_config/fish packages/common.txt`. Si la capa se aplicó con chezmoi: `chezmoi --source <repo>/home/common` remove sobre el archivo o editar/eliminar la capa y reaplicar.

## Git

- Commit: `feat(fish): add Omarchy-compatible fish startup config` — `f4abd47`.
- Commit: `chore(packages): add fish to common manifest` — `96f2930`.
