---
name: workstation-state
description: "Trigger: solved, chezmoi, desired state, rollback, restore, dotfiles, scope. Clasifica cambios por perfil y consolida el estado validado en el repositorio."
license: Apache-2.0
metadata:
  author: "juan"
  version: "1.0"
---

# Workstation State

## Contrato de activación

Activa esta skill para clasificar cambios por perfil, administrar el desired state con chezmoi y consolidar soluciones validadas (`/solved`).

## Reglas duras

- El desired state (archivos chezmoi + manifiestos de paquetes) es la fuente de verdad; la documentación de `knowledge/` explica el porqué, nunca es la fuente del estado.
- Solo `/solved` consolida el estado validado. Sin `/solved` no se hace commit de la solución.
- Prohibido guardar secretos: tokens, passwords, private keys, API keys, `.env` con secretos, claves SSH privadas.
- Commits pequeños, atómicos y relacionados; NUNCA `git add -A`.

## Clasificación por scope

| Scope | Capa |
|---|---|
| Todos los equipos | `home/common/` |
| Ajustes de Omarchy | `home/omarchy/` |
| Clase de dispositivo | `home/profiles/desktop/` o `home/profiles/laptop/` |
| Máquina concreta | `home/profiles/machines/<hostname>/` |

## Uso correcto de chezmoi

Cada capa es un directorio fuente independiente. Aplicar SIEMPRE en este orden (la posterior sobrescribe a la anterior):

```bash
chezmoi apply --source "<repo>/home/common"
chezmoi apply --source "<repo>/home/omarchy"
chezmoi apply --source "<repo>/home/profiles/desktop"      # o laptop, según la clase
chezmoi apply --source "<repo>/home/profiles/machines/<perfil>"  # si existe la capa
```

Inspección: `chezmoi --source "<repo>/home/<capa>" status` y `chezmoi --source "<repo>/home/<capa>" diff`.

## Pasos en /solved

1. Inspeccionar: `git status`, `git diff` y chezmoi status/diff por capa.
2. Clasificar el scope en una sola capa.
3. Capturar solo el estado final necesario en la capa correcta, preferiblemente con chezmoi directo.
4. Registrar paquetes en el manifiesto correcto, sin duplicados.
5. Documentar en `knowledge/solved/YYYY-MM-DD-slug.md` con frontmatter ligero y los encabezados exactos; antes de crear la entrada, buscar duplicados con `rg -l` en `knowledge/solved/`.
6. Verificar con `scripts/verify` y validadores nativos; no inventar validadores.
7. Idempotencia en scripts (aplicar → verificar → aplicar → verificar).
8. Commit pequeño con conventional commits; push solo si hay remote.

## Rollback y restore

- Restore: descarta cambios experimentales sin consolidar: `git checkout -- <rutas>` + reaplicar capas en orden.
- Rollback: `scripts/rollback <componente>` o `scripts/rollback --commit <hash> <componente>`; nunca toca componentes ajenos.
- Verificar después con `scripts/verify`.

## Contrato de salida

- Repo consolidado y verificado; lista de archivos del commit y referencia a la entrada de knowledge.
