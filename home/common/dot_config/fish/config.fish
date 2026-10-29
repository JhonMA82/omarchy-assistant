# config.fish — adaptación del init interactivo de Omarchy a fish.
# Se mantiene en la capa common del overlay y se aplica con chezmoi.

if status is-interactive
    # Sin mensaje de bienvenida de fish.
    set -g fish_greeting ""

    # Prompt: starship (mismo que en bash; tema en ~/.config/starship.toml).
    if command -q starship
        starship init fish | source
    end
end

# pnpm — bloque generado por el instalador oficial
# (curl -fsSL https://get.pnpm.io/install.sh | sh -). Se conserva literal para
# que chezmoi apply lo mantenga y para que reinstalarlo sea idempotente.
set -gx PNPM_HOME '/home/juan/.local/share/pnpm'
if test "$PATH[1]" != "$PNPM_HOME/bin"
  set -gx PATH "$PNPM_HOME/bin" $PATH
end
# pnpm end
