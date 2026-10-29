---
component: git
scope: machine-local
machine: omarchy
tags:
  - git
  - mise
  - gh
  - credential-helper
  - push
---

# `git push` fallaba: credential helper con ruta de gh versionada rota

## Problema

`git push origin main` se abortaba sin llegar a autenticar:

```text
/home/juan/.local/share/mise/installs/gh/2.97.0/gh_2.97.0_linux_amd64/bin/gh:
No existe el fichero o el directorio
fatal: could not read Username for 'https://github.com': No existe el dispositivo o la dirección
```

## Causa

Dos cosas apiladas:

1. `~/.config/git/config` declaraba el credential helper apuntando a una ruta
   **absoluta y versionada** dentro de mise:

   ```ini
   [credential "https://github.com"]
   	helper =
   	helper = !/home/juan/.local/share/mise/installs/gh/2.97.0/gh_2.97.0_linux_amd64/bin/gh auth git-credential
   ```

   (igual para `https://gist.github.com`)

2. mise actualizó `gh` y **eliminó `2.97.0`**. Quedan 2.98.0 … 2.103.3, así que la
   ruta quedó colgando. El helper ni siquiera se ejecuta: git aborta al no poder
   resolver el binario.

Agravante: `gh` tampoco estaba fijado en el `[tools]` global de mise, así que
incluso el shim (`~/.local/share/mise/shims/gh`) fallaba con
`No version is set for shim: gh`. Mismo patrón que
`2026-10-29-mise-shim-node-sin-version-global.md`.

## Solución validada

Dos cambios mínimos:

**1. Fijar el default global de gh en mise** (evita que el shim aborte):

```bash
mise use -g gh@2.103.3
```

**2. Repuntar el credential helper al shim**, que es independiente de versión:

```ini
[credential "https://github.com"]
	helper =
	helper = !/home/juan/.local/share/mise/shims/gh auth git-credential
[credential "https://gist.github.com"]
	helper =
	helper = !/home/juan/.local/share/mise/shims/gh auth git-credential
```

Verificado: `gh auth status` → `✓ Logged in to github.com account JhonMA82 (keyring)`;
`git credential fill` resuelve credenciales; `git push` → `287b7c1..10e7ce6  main -> main`.

## Scope

**Local a esta máquina, fuera del desired state de chezmoi.**

Ni `~/.config/git/config` ni `~/.config/mise/config.toml` están gestionados por
chezmoi. Son ajustes de entorno, no reglas de dotfiles del overlay.

## Archivos afectados

- `~/.config/git/config` — dos líneas `helper` repuntadas al shim de mise.
- `~/.config/mise/config.toml` — añadido `gh = "2.103.3"` en `[tools]`.

Ningún archivo del repositorio cambió.

## Verificación

```bash
git config --get credential."https://github.com".helper
# → !/home/juan/.local/share/mise/shims/gh auth git-credential

printf 'protocol=https\nhost=github.com\n\n' | git credential fill   # resuelve user/pass
gh auth status          # ✓ Logged in to github.com account JhonMA82
git push origin main    # funciona
```

Sin validador de chezmoi: no es una capa gestionada (WARN esperado).

## Rollback

```bash
# Restaurar la ruta versionada anterior en ~/.config/git/config
# y quitar la línea gh de ~/.config/mise/config.toml.
```

No afecta a ningún componente de Omarchy.

## Git

Sin commit de solución: ambos archivos viven en `~/.config/`, fuera del repo y
fuera del desired state de chezmoi. Solo se consolida esta entrada de knowledge.

## Regla reutilizable

**Nunca hardcodear rutas `~/.local/share/mise/installs/<tool>/<versión>/...` en
configs de git, ssh u otras herramientas.** Esas rutas desaparecen cuando mise
actualiza o limpia versiones. Usar siempre el shim `~/.local/share/mise/shims/<tool>`
— que resuelve la versión fijada en el `[tools]` global — y fijarla con
`mise use -g <tool>@<version>`.

Diagnóstico rápido: si algo falla con `No version is set for shim: <X>` o con
`No existe el fichero o el directorio` apuntando a `installs/`, comprueba si ese
runtime está fijado globalmente en mise.
