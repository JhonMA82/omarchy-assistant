---
description: Consolida la solución validada por el usuario en el estado reproducible: clasifica, documenta, verifica, commitea y hace push.
---

El usuario acaba de validar manualmente que una solución funciona y ejecutó `/solved`. Consolida esa solución como estado reproducible conocido. Ejecuta los pasos en orden; no te saltes ninguno.

## 0. Guard: chezmoi disponible (fail-closed)

Antes de cualquier uso de chezmoi, comprueba que esté instalado:

```bash
command -v chezmoi
```

Si no existe, **DETENTE aquí** y muestra exactamente:

```text
Chezmoi no está disponible.
No se puede validar el desired state.
Ejecuta bootstrap o instala chezmoi y vuelve a ejecutar /solved.
```

En ese caso NO: marques known-good, afirmes que verify pasó, crees el commit final ni hagas push. Deja el working tree intacto para poder reintentarlo después.

## 1. Inspeccionar

Trabaja sobre el **delta de la sesión** (`git status`, `git diff`, `git diff --cached` y chezmoi status/diff por capa), no sobre el estado completo del repositorio. No releas la arquitectura, el árbol de `knowledge/` ni la infraestructura: el contexto de la sesión ya lo tienes; revisa únicamente los archivos relacionados con el delta.

- Ejecuta `git status` y `git diff`.
- Ejecuta, por cada capa en el orden canónico (common → omarchy → desktop|laptop → machines/<perfil>):
  - `chezmoi --source <repo>/home/<capa> status`
  - `chezmoi --source <repo>/home/<capa> diff`
- Determina qué cambió: archivos modificados, archivos temporales, cambios experimentales y cambios realmente necesarios para la solución. No asumas que todo el working tree pertenece a la solución.

## 2. Clasificar el scope

Clasifica cada cambio en una sola capa: `common` (todos los equipos), `omarchy` (ajustes de Omarchy), `desktop` o `laptop` (clase de dispositivo) o `machines/<hostname>` (específico de una máquina).

## 3. Actualizar el desired state con chezmoi

- Captura únicamente el estado final necesario, en la capa correcta (`home/<capa>/dot_config/...`).
- Prefiere usar chezmoi directamente (por ejemplo `chezmoi add --source <repo>/home/<capa> <archivo>` o editar los archivos en la capa). No crees scripts para lo que chezmoi ya resuelve.
- Cada capa se aplica en este orden exacto (la posterior sobrescribe a la anterior):

```bash
chezmoi apply --source "<repo>/home/common"
chezmoi apply --source "<repo>/home/omarchy"
chezmoi apply --source "<repo>/home/profiles/desktop"      # o laptop, según la clase
chezmoi apply --source "<repo>/home/profiles/machines/<perfil>"  # si existe la capa
```

## 4. Registrar paquetes

Si la solución requirió una aplicación instalada de forma persistente, agrégala al manifiesto correcto (`packages/common.txt`, `packages/desktop.txt`, `packages/laptop.txt` o `packages/machines/<perfil>.txt`): una línea por paquete, comentarios con `#`, sin duplicados, clasificada por scope. Solo repos oficiales de pacman; AUR queda fuera de v0.1.

## 5. Documentar

Antes de crear la entrada, busca duplicados de forma barata:

```bash
rg -l -i '<componente>|<palabras clave del problema>' knowledge/solved/
```

Si existe una entrada claramente equivalente, actualízala o enlázala desde la nueva entrada. No leas todos los resultados indiscriminadamente, ni el resto de `knowledge/`.

Crea `knowledge/solved/YYYY-MM-DD-slug.md` (fecha de hoy, slug corto) con frontmatter ligero y estos encabezados EXACTOS, en este orden:

```markdown
---
component: starship
scope: common
machine: all
tags:
  - shell
  - prompt
  - performance
commit: 8af29c1
---

# Título

## Problema

## Causa

## Solución validada

## Scope

## Archivos afectados

## Verificación

## Rollback

## Git
```

Campos de frontmatter opcionales si no aplican: `component`, `scope`, `machine`, `tags`, `commit`. Su propósito es permitir búsquedas baratas con `rg` (ejemplo: `rg -l 'component: starship' knowledge/solved/`). No agregues esquemas ni validadores de metadata.

Documenta solo conocimiento útil y reutilizable. No copies conversaciones completas.

## 6. Verificar

- Ejecuta `scripts/verify`.
- Usa los validadores nativos disponibles: `fish -n` para Fish, `starship print-config` para Starship, `ghostty +show-config` para Ghostty, `chezmoi --source <capa> diff` por capa.
- No inventes validadores ficticios; si una herramienta no tiene validador, infórmalo como WARN.

## 7. Comprobar idempotencia (solo cuando aplique)

Si la solución usa scripts de aplicación, ejecuta aplicar → verificar → aplicar → verificar. La segunda pasada no debe introducir cambios adicionales. No ejecutes esta secuencia para archivos estáticos administrados directamente por chezmoi.

## 8. Commit

- Solo archivos de la solución. NUNCA `git add -A`; revisa primero qué pertenece a la solución.
- Commits pequeños y relacionados, formato conventional commits. Ejemplos: `fix(starship): remove slow custom command`, `fix(fish): restore valid startup configuration`, `feat(hypr): add vertical secondary monitor layout`, `chore(packages): add required desktop utility`.
- No registres archivos temporales, logs ni secretos.

## 9. Push

Haz push solo si existe remote configurado y el usuario ha establecido que este repositorio debe sincronizarse automáticamente. Si no hay remote, no falles por ello.

## No debes

- Hacer `git add -A` sin revisar.
- Incluir cambios ajenos a la solución.
- Consolidar (known-good, commit o push) cuando chezmoi no esté disponible: el guard del paso 0 lo impide.
- Releer todo el repositorio o recorrer `knowledge/` completo durante `/solved`: usa el delta de la sesión y la búsqueda dirigida.
- Crear múltiples capas de abstracción ni scripts para configuraciones que chezmoi administra directamente.
- Modificar internals de Omarchy sin necesidad.
- Convertir cada solución en una nueva «feature».
- Crear agentes adicionales automáticamente.
- Instalar dependencias nuevas innecesarias.
- Guardar secretos: nunca tokens, passwords, private keys, API keys, `.env` con secretos, credenciales Wi-Fi ni claves SSH privadas. Si una configuración los necesita, referencia variables de entorno o un secret manager existente y documenta la dependencia.
