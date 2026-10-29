---
component: mise
scope: machine-local
machine: omarchy
tags:
  - mise
  - node
  - shim
  - bun
  - pi
---

# `pi` fallaba: shim de mise sin versión global de node

## Problema

Ejecutar `pi update` (o cualquier binario de bun global escrito en Node) fallaba con:

```text
mise ERROR No version is set for shim: node
Set a global default version with one of the following:
mise use -g node@26.7.0
mise use -g node@26.8.2
mise use -g node@26.12.1
mise ERROR Version: 2026.10.21 linux-x64 (2026-10-27)
```

El comando se abortaba antes de hacer nada.

## Causa

`pi` no es un binario compilado: `/home/juan/.bun/bin/pi` es un enlace a
`~/.bun/install/global/node_modules/@earendil-works/pi-coding-agent/dist/bundle/cli.js`,
con shebang `#!/usr/bin/env node`.

El `PATH` de esta máquina resuelve `node` a través de los **shims de mise**
(`~/.local/share/mise/shims/node`), no de un binario directo. El config global
`~/.config/mise/config.toml` declaraba en `[tools]` únicamente `go`, `grok`,
`herdr` y `uv` — **sin `node`**. Con tres versiones de node instaladas
(26.7.0, 26.8.2, 26.12.1) y ninguna fijada como global, el shim no sabe cuál
resolver y aborta en lugar de degradar.

O sea: el problema no era `pi` ni `bun`, sino que un shim de mise apuntaba a un
runtime que nunca se fijó.

## Solución validada

Fijar una versión global por defecto de node en el config de mise:

```bash
mise use -g node@26.12.1
```

Esto añade `node = "26.12.1"` al `[tools]` de `~/.config/mise/config.toml`.
Se eligió la versión más reciente ya instalada (no el canal `latest`) para
reproducibilidad.

Verificado tras el cambio: `node --version` → `v26.12.1`, `pi --version` → `1.4.0`.

## Scope

**Local a esta máquina, fuera del desired state de chezmoi.**

`~/.config/mise/config.toml` **no está gestionado por chezmoi** — `chezmoi
managed` no lo lista y ninguna capa del repo contiene un `dot_config/mise/`.
Es un ajuste de entorno de la máquina, no una regla de dotfiles.

No se movió a una capa `home/common/` deliberadamente: habría sido una expansión
de alcance no validada y daría a chezmoi control sobre un config que hoy contiene
definiciones de tools con URLs (p. ej. `grok`), con riesgo de sobrescribirlo.

## Archivos afectados

- `~/.config/mise/config.toml` — añadido `node = "26.12.1"` en `[tools]` (no versionado).

Ningún archivo del repositorio cambió.

## Verificación

```bash
command -v node          # → ~/.local/share/mise/shims/node (shim de mise)
node --version           # → v26.12.1
pi --version             # → 1.4.0
mise ls node             # → 26.12.1 marcada como default
```

No hay validador nativo de chezmoi para este cambio porque no es una capa
gestionada (WARN esperado).

## Rollback

```bash
# Eliminar la línea añadida de ~/.config/mise/config.toml, o fijar otra versión:
mise use -g node@<version-anterior>

# Si se quiere eliminar por completo el default de node:
# borrar la línea node del bloque [tools] de ~/.config/mise/config.toml
```

No afecta a ningún componente de Omarchy ni a otros dotfiles.

## Git

Sin commit de solución: el cambio vive en `~/.config/mise/config.toml`, fuera del
repositorio y fuera del desired state de chezmoi. Solo se consolida esta entrada
de knowledge, que documenta el diagnóstico reutilizable.

**Regla reutilizable:** si un CLI instalado globalmente vía bun falla con
`No version is set for shim: <runtime>`, comprueba primero si su binario es un
script Node y, en tal caso, si mise tiene ese runtime fijado como versión global.
