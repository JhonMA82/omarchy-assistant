---
component: nvim
scope: common
machine: all
tags:
  - neovim
  - jinja
  - filetype
  - treesitter
commit: f5c1b62
---

# Soporte .jinja en nvim con lenguaje anfitrión

## Problema

Los archivos `*.jinja` se abrían con filetype `jinja` y casi sin color: solo los
delimitadores `{{ }}`, `{% %}` se resaltaban. Caso real: plantillas Rust como
`crates/engine/src/lib.rs.jinja`, donde se esperaba ver colores de Rust.

## Causa

- Neovim detecta `.jinja` como filetype `jinja` por defecto.
- El parser `tree-sitter-jinja` es de resaltado básico por diseño: solo tiñe
  delimitadores y deja el resto (HTML, Rust, YAML…) sin color.
- Detalle adicional: `vim.filetype.add()` ancla los patrones con `^...$`
  automáticamente; una clave como `.*%.jinja$` se convierte en `^.*%.jinja$$`
  y nunca matchea.

## Solución validada

Regla en `ftdetect` que deriva el filetype del lenguaje anfitrión quitando el
sufijo `.jinja` (`lib.rs.jinja` → `rust`, `Cargo.toml.jinja` → `toml`,
`play.yml.jinja` → `yaml`); `.jinja` plano conserva `jinja`. Más parsers
treesitter `jinja`, `jinja_inline` y `rust` en el spec de LazyVim.

## Scope

common: configuración de editor válida para todos los equipos.

## Archivos afectados

- `home/common/dot_config/nvim/ftdetect/jinja.lua`
- `home/common/dot_config/nvim/lua/plugins/jinja.lua`

## Verificación

- `nvim --headless --clean --cmd "source ~/.config/nvim/ftdetect/jinja.lua"`
  con `vim.filetype.match`: `lib.rs.jinja` → rust, `Cargo.toml.jinja` → toml,
  `README.md.jinja` → markdown, `template.jinja` → jinja, `play.yml.jinja` →
  yaml, `Dockerfile.jinja` → dockerfile.
- Apertura real de `lib.rs.jinja` con la config completa: `ft=rust` y
  auto-instalación del parser (`tree-sitter-rust`).
- Usuario validó colores de Rust tras reiniciar nvim.

## Rollback

- `chezmoi --source "<repo>/home/common" apply` tras borrar los dos archivos
  de la capa, o `rm ~/.config/nvim/ftdetect/jinja.lua
  ~/.config/nvim/lua/plugins/jinja.lua` para el estado local.

## Git

Commit `f5c1b62` (`feat(nvim): soporte .jinja con lenguaje anfitrión y parsers
treesitter`) + esta entrada.
