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
