---
component: fish
scope: common
machine: all
tags:
  - fish
  - path
  - bun
  - pi
  - omp
  - chezmoi
commit: 2cc1d42
---

# `bun`, `pi` y `omp` desaparecieron: chezmoi borró el bloque `# bun` del instalador

## Problema

Los comandos `omp` (oh-my-pi), `pi` (pi-agent) y `bun` dejaron de detectarse en la
terminal (`command not found`), aunque los binarios existían en `~/.bun/bin/` y
seguían funcionando con rutas absolutas.

## Causa

Dos escritores sobre el mismo fichero:

1. El instalador oficial de bun (`curl -fsSL https://bun.sh/install | bash`)
   *appendea* un bloque `# bun` con `BUN_INSTALL` y el PATH al final de
   `~/.config/fish/config.fish`.
2. Ese fichero lo gestiona chezmoi desde `home/common/dot_config/fish/config.fish`.
   Cualquier `chezmoi apply` lo re-escribe para igualarlo a la fuente del overlay y
   descarta lo añadido fuera del repo, sin backup.

El 2026-10-29 a las 10:27 se corrió el instalador de bun (añadió el bloque); a las
11:28 el commit `28a0ce2` (bloque pnpm) su apply borró el bloque `# bun`. Las
terminales abiertas conservaban el PATH viejo, por eso el fallo solo apareció en
sesiones nuevas. Mismo patrón que el incidente previo de pnpm (ver commit `28a0ce2`).

## Solución validada

Replicar el bloque literal del instalador en la capa `common`, como ya se hizo con
pnpm, para que `chezmoi apply` lo conserve en vez de borrarlo:

```fish
# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH "$BUN_INSTALL/bin" $PATH
# bun end
```

## Scope

`common` — todos los equipos. Inofensivo en máquinas sin `~/.bun/bin` (la entrada
PATH apunta a un directorio inexistente; ningún binario en conflicto).

## Archivos afectados

- `home/common/dot_config/fish/config.fish`

## Verificación

- `chezmoi --source <repo>/home/common status` y `diff`: limpios tras apply.
- `fish -c 'command -q bun; command -q omp; command -q pi'`: los tres resuelven
  (`bun 1.4.4`, `omp 18.14.0`, `pi 1.4.0`).

## Rollback

Eliminar el bloque `# bun … # bun end` del config.fish de la capa common y volver
a aplicar:

```bash
chezmoi apply --source "<repo>/home/common"
```

## Git

- Commit: `2cc1d42 fix(fish): add bun PATH block from official installer`
- Relacionado: `28a0ce2 feat(fish): add pnpm PATH block from official installer`
