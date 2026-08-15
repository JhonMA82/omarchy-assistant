# AGENTS.md — Guía para agentes

Proyecto: Omarchy Assistant. **Idioma del proyecto: español.** Todos los artefactos (documentación, comentarios, mensajes de commit, skills, entries de knowledge) se escriben en español neutro y profesional; los identificadores técnicos (comandos, flags, prefijos de conventional commits como `fix(starship):`) se mantienen convencionales.

## Principios

- Minimizar cambios: resolver solo el problema real.
- No sobre-ingenierizar; no instalar herramientas innecesarias.
- Respetar Omarchy upstream: este proyecto es un overlay, no un fork.
- chezmoi es la fuente de verdad de los dotfiles.
- Git es la fuente de verdad del historial.
- Trabajar primero en el problema real, no en hipótesis.
- Solo `/solved` consolida el estado.

## Durante una solución

1. Investigar el problema real (configuración actual, logs, documentación relevante).
2. Diagnosticar la causa raíz.
3. Cambiar lo mínimo necesario para resolverlo.
4. Permitir que el usuario pruebe el cambio.
5. Esperar la validación del usuario.
6. Consolidar con `/solved` solo después de la validación.

## Capas de chezmoi (orden obligatorio)

```text
common → omarchy → desktop|laptop → machines/<perfil>
```

Cada capa es un directorio fuente independiente. Aplicar siempre en este orden; la capa posterior sobrescribe a la anterior:

```bash
chezmoi apply --source "<repo>/home/common"
chezmoi apply --source "<repo>/home/omarchy"
chezmoi apply --source "<repo>/home/profiles/desktop"           # o laptop, según la clase
chezmoi apply --source "<repo>/home/profiles/machines/<perfil>" # si existe la capa
```

Inspección: `chezmoi --source "<repo>/home/<capa>" status` y `chezmoi --source "<repo>/home/<capa>" diff`.

## Prohibido

- Commits automáticos antes de la validación del usuario.
- Push antes de `/solved`.
- Grandes refactors no solicitados.
- Cambios fuera del problema.
- Guardar credenciales o secretos (tokens, passwords, private keys, API keys, `.env` con secretos, claves SSH privadas).
- `git add -A` sin revisar qué pertenece a la solución.
