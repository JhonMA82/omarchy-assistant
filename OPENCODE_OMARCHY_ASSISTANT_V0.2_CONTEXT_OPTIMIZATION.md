# OpenCode Instructions — Omarchy Assistant v0.2 Context Discipline

## Objetivo

Optimizar el proyecto existente **Omarchy Assistant** para reducir lecturas innecesarias, consumo de contexto y tokens durante sesiones normales de diagnóstico y durante `/solved`.

La implementación actual funciona y **NO debe rediseñarse**.

Esta iteración debe ser un ajuste pequeño y focalizado sobre:

- carga selectiva de contexto;
- búsqueda antes de lectura;
- `knowledge/` bajo demanda;
- `/solved` basado en el delta real de la sesión;
- evitar releer archivos de infraestructura irrelevantes;
- mantener el comportamiento actual del proyecto.

---

## Principio rector

Aplicar esta regla en toda la implementación:

> No cargar información que no sea necesaria para resolver la tarea actual.

Preferir siempre:

```text
SEARCH
↓
SELECT
↓
READ
```

en lugar de:

```text
READ EVERYTHING
↓
DECIDE
```

El objetivo no es crear un sistema de RAG, indexación avanzada, embeddings ni memoria adicional.

Usar las herramientas existentes y mantener la solución minimalista.

---

## Restricciones obligatorias

NO implementar:

- base de datos;
- SQLite;
- embeddings;
- vector store;
- RAG propio;
- MCP de memoria;
- daemon;
- indexador residente;
- watcher;
- caché compleja;
- servicio de background;
- nuevas dependencias salvo necesidad estrictamente demostrada;
- refactor grande del repositorio;
- cambio de arquitectura general;
- nueva capa de abstracción para leer archivos.

La solución debe basarse principalmente en:

- instrucciones claras para OpenCode;
- `rg`;
- Git;
- chezmoi;
- metadata Markdown ligera cuando aporte valor;
- lectura selectiva.

---

## 1. Comportamiento de contexto por defecto

Modificar las instrucciones del proyecto para que OpenCode **NO recorra ni lea recursivamente el repositorio al comenzar una sesión**.

El contexto mínimo inicial debe ser únicamente el necesario para operar.

Conceptualmente:

```text
ALWAYS RELEVANT
├── AGENTS.md
├── identidad/perfil de máquina actual
├── git status
└── skill directamente relevante para la tarea
```

No asumir que otros archivos necesitan leerse.

---

## 2. Archivos que NO deben cargarse automáticamente

OpenCode no debe leer por defecto:

```text
knowledge/**
bootstrap.sh
scripts/rollback
scripts/doctor
profiles de otras máquinas
configuraciones de componentes no relacionados
references completas de skills
```

Estos archivos solo deben abrirse cuando exista una razón concreta relacionada con la tarea actual.

---

## 3. `knowledge/` debe ser lazy-loaded

Actualmente `knowledge/` puede ser pequeño, pero crecerá con el uso.

Cambiar el comportamiento para que:

> `knowledge/` sea una fuente histórica consultable bajo demanda, no contexto de inicio.

### Regla obligatoria

Nunca leer de forma recursiva todos los documentos dentro de:

```text
knowledge/
knowledge/solved/
knowledge/manual/
```

durante:

- startup;
- diagnóstico normal;
- `/solved`;
- verificación general de una solución.

---

## 4. Estrategia para consultar knowledge

Cuando exista una razón para buscar antecedentes:

```text
identificar componente/problema
↓
buscar filenames/metadata/contenido con rg
↓
seleccionar coincidencias relevantes
↓
leer únicamente esos archivos
```

Ejemplo:

Problema:

```text
Starship tarda demasiado en mostrar el prompt
```

Buscar primero:

```bash
rg -l -i 'starship|prompt|shell startup|startup performance' knowledge/
```

Solo después leer los documentos relevantes encontrados.

No leer otros documentos de:

- Hyprland;
- Bluetooth;
- monitores;
- Ghostty;
- paquetes;
- otros problemas sin relación.

---

## 5. Política search-before-read

Agregar explícitamente a `AGENTS.md` una sección equivalente a:

```text
Context discipline

Do not preload or recursively read the repository.

Start with the smallest context required for the current task.

Before reading a file, determine whether it is needed for the current
diagnosis or decision.

Prefer:
search -> targeted read

over:
recursive repository reads.

Historical knowledge is opt-in context.

Infrastructure files are read only when the task affects that
infrastructure.
```

Adaptar la redacción al estilo actual del repositorio.

No duplicar reglas ya existentes.

---

## 6. Routing mínimo por tipo de tarea

No crear un router ejecutable.

Agregar únicamente reglas de decisión para el agente.

### Fish

Si el problema afecta Fish:

Leer potencialmente:

```text
configuración Fish relevante
skill/referencia Fish relevante
knowledge relacionado encontrado mediante búsqueda
```

No leer automáticamente:

```text
bootstrap.sh
monitor configs
laptop profile
rollback implementation
todos los documentos knowledge
```

### Starship

Leer:

```text
starship config
integración Fish si realmente afecta el prompt
knowledge Starship relacionado si existe
```

No cargar el resto del repositorio.

### Hyprland / monitores

Leer:

```text
config Hyprland directamente involucrada
perfil de la máquina actual
knowledge relacionado mediante búsqueda
```

No leer:

```text
Fish
Starship
otros perfiles
bootstrap.sh
```

salvo dependencia demostrada.

### Paquetes / instalación

Leer:

```text
package manifest relevante
perfil actual
```

Leer `bootstrap.sh` únicamente si:

- se necesita cambiar el proceso de bootstrap;
- existe un problema de reinstalación;
- la instalación persistente del paquete depende directamente de su lógica.

---

## 7. `bootstrap.sh` debe ser contexto bajo demanda

Agregar una regla explícita:

OpenCode debe leer `bootstrap.sh` solamente cuando la tarea esté relacionada con:

- bootstrap;
- reinstalación;
- configuración inicial;
- paquetes que el bootstrap instala o administra;
- errores dentro del bootstrap;
- cambios que deban persistir mediante ese script.

No leer `bootstrap.sh` para tareas como:

```text
cambiar Starship
modificar Fish
ajustar Waybar
cambiar Ghostty
cambiar layout de monitor
ajustar Hyprland
```

salvo que exista una dependencia directa demostrable.

---

## 8. Scripts de infraestructura bajo demanda

Aplicar la misma regla a:

```text
scripts/rollback
scripts/doctor
scripts/verify
```

### `rollback`

Leer solamente cuando:

- el usuario solicita rollback;
- el usuario solicita restore;
- una solución requiere recuperar una versión;
- se está modificando el propio mecanismo de rollback.

### `doctor`

Leer solamente cuando:

- se diagnostica el proyecto;
- se modifica `doctor`;
- el problema está relacionado directamente con información producida por él.

### `verify`

Puede utilizarse cuando corresponda para validar.

No es necesario leer toda su implementación antes de cada solución si basta con ejecutarlo o ejecutar un check específico.

---

## 9. Skills: evitar carga excesiva

Revisar las skills existentes.

Objetivo:

- `SKILL.md` pequeño;
- instrucciones operativas;
- reglas de decisión;
- referencias separadas por tema si actualmente existe documentación extensa.

Ejemplo aceptable:

```text
.opencode/skills/omarchy-maintainer/
├── SKILL.md
└── references/
    ├── fish.md
    ├── starship.md
    ├── hyprland.md
    ├── waybar.md
    └── ghostty.md
```

`SKILL.md` debe indicar cuándo leer cada referencia.

No debe requerir que todas las referencias sean cargadas siempre.

### Importante

No hacer esta separación si los skills actuales ya son pequeños.

Evitar refactor por estética.

Aplicarlo únicamente donde reduzca claramente contexto innecesario.

---

## 10. Optimizar `/solved`

`/solved` no debe redescubrir todo el repositorio.

Debe trabajar principalmente sobre:

```text
contexto actual de la sesión
+
git status
+
git diff
+
chezmoi status/diff cuando aplique
```

Flujo objetivo:

```text
usuario valida solución
↓
/solved
↓
inspeccionar delta actual
↓
identificar archivos realmente afectados
↓
clasificar scope
↓
capturar desired state necesario
↓
verificación relevante
↓
crear/actualizar knowledge
↓
commit
↓
push si corresponde
```

No:

```text
/solved
↓
leer todo el repo
↓
leer todo knowledge
↓
leer bootstrap
↓
leer todos los scripts
↓
reconstruir arquitectura
```

---

## 11. `/solved` debe ser delta-oriented

El foco de `/solved` debe ser:

> ¿Qué cambió para resolver este problema?

No:

> ¿Cuál es el estado completo del repositorio?

Usar principalmente:

```bash
git status --short
git diff
git diff --cached
```

y:

```bash
chezmoi status
chezmoi diff
```

cuando sea relevante.

Revisar únicamente los archivos relacionados con el delta.

---

## 12. No usar `git add -A` ciegamente

Mantener/reforzar esta regla.

Antes de versionar:

1. identificar cambios de la solución;
2. excluir cambios temporales;
3. excluir experimentos descartados;
4. excluir cambios ajenos a la sesión;
5. versionar únicamente el estado final validado.

---

## 13. Knowledge durante `/solved`

No leer knowledge histórico completo.

Consultar knowledge únicamente si aporta una decisión concreta.

### Buscar duplicado

Antes de crear una entrada nueva, puede realizarse una búsqueda pequeña:

```bash
rg -l -i '<component>|<problem keywords>' knowledge/solved/
```

Si existe una entrada claramente equivalente:

- considerar actualizarla;
- o enlazarla desde la nueva entrada.

No leer todos los resultados indiscriminadamente.

### Relacionar antecedente

Si el problema actual es continuación de uno anterior:

- buscar;
- seleccionar;
- leer esa entrada;
- relacionarla.

---

## 14. Metadata ligera en knowledge

Agregar frontmatter ligero a nuevas entradas si actualmente no existe algo equivalente.

Formato recomendado:

```yaml
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
```

No todos los campos son obligatorios si no aplican.

Campos recomendados:

```text
component
scope
machine
tags
commit
```

Objetivo:

Permitir búsquedas baratas con `rg`.

Ejemplos:

```bash
rg -l 'component: starship' knowledge/solved/
rg -l 'scope: desktop-main' knowledge/solved/
```

No agregar esquemas complejos ni validadores de metadata en esta versión.

---

## 15. `INDEX.md` opcional y ligero

Evaluar si un:

```text
knowledge/INDEX.md
```

aporta valor real.

Si se implementa:

- debe ser pequeño;
- no repetir el contenido de las soluciones;
- actuar solo como índice temático;
- actualizarse desde `/solved` de forma sencilla.

Ejemplo:

```markdown
# Knowledge Index

## Starship
- Slow prompt startup
- Git status customization

## Fish
- Startup syntax failure

## Hyprland
- Desktop-main vertical monitor
```

### Importante

Si `rg + frontmatter` ya resuelve adecuadamente la recuperación:

> NO implementar `INDEX.md`.

Elegir la solución más simple.

---

## 16. No leer perfiles de otras máquinas

Cuando la sesión se ejecuta en:

```text
desktop-main
```

no leer automáticamente:

```text
laptop-main
other-desktop
other-machine
```

La máquina actual debe limitar el contexto.

Leer otros perfiles solo cuando:

- se compara comportamiento;
- se mueve una configuración entre equipos;
- se modifica una regla compartida;
- el usuario lo solicita.

---

## 17. Contexto de cuatro niveles

Documentar conceptualmente este modelo, sin implementarlo como framework:

### Level 0 — Core

```text
AGENTS.md
current machine/profile
git status
```

### Level 1 — Task

```text
archivo/configuración directamente involucrada
skill relevante
```

### Level 2 — Historical

```text
knowledge buscado y seleccionado
```

### Level 3 — Infrastructure

```text
bootstrap
rollback internals
doctor internals
otros scripts
```

Regla:

> Escalar de nivel únicamente cuando la tarea lo requiera.

---

## 18. Flujo esperado — ejemplo Starship

Ante:

```text
Starship tarda mucho en mostrar el prompt
```

el flujo esperado es:

```text
OpenCode inicia
↓
lee instrucciones mínimas
↓
detecta current machine
↓
git status
↓
identifica component=starship
↓
lee starship config
↓
busca antecedentes con rg
↓
lee solo 0-N resultados relevantes
↓
diagnostica
↓
modifica
↓
usuario valida
↓
/solved
↓
git diff
↓
chezmoi diff si aplica
↓
verificación relacionada
↓
knowledge entry
↓
commit
```

Durante ese flujo normalmente NO debe leer:

```text
bootstrap.sh
scripts/rollback
monitor configs
laptop profile
knowledge no relacionado
otros componentes
```

---

## 19. Flujo esperado — ejemplo monitor

Ante:

```text
El monitor secundario debe quedar vertical
```

el flujo esperado es:

```text
current machine = desktop-main
↓
identificar Hyprland/monitor config
↓
leer solo config actual del monitor
↓
buscar antecedentes de monitor/hyprland si aporta valor
↓
modificar
↓
usuario valida
↓
/solved
↓
capturar como machine-specific
↓
verify relevante
↓
knowledge
↓
commit
```

No leer automáticamente:

```text
Starship
Fish
bootstrap
laptop profile
todo knowledge
```

---

## 20. README

Actualizar la documentación únicamente donde sea necesario para explicar:

- context discipline;
- lazy knowledge;
- search-before-read;
- `/solved` delta-oriented.

No reescribir todo el README.

Mantener documentación enfocada al usuario.

---

## 21. AGENTS.md

Esta debe ser la principal fuente para controlar el comportamiento de contexto.

Agregar o refinar una sección clara con reglas como:

```text
## Context Discipline

- Do not recursively preload the repository.
- Read only files required by the active task.
- Prefer search before reading historical knowledge.
- Do not read all knowledge entries.
- Do not read bootstrap or infrastructure scripts unless relevant.
- Do not inspect profiles for other machines unless needed.
- Use the current session delta during /solved.
- Reuse conversation/task context instead of rediscovering the repository.
```

Integrarlo limpiamente con las reglas actuales.

No duplicar instrucciones existentes.

---

## 22. Criterios de aceptación

La optimización está terminada cuando se pueden verificar estos casos.

### Caso A — Starship

Solicitar un cambio simple de Starship.

Esperado:

```text
READ:
✓ instrucciones mínimas
✓ current profile
✓ starship config
? knowledge Starship relevante

NOT READ:
✗ bootstrap.sh
✗ rollback
✗ perfiles ajenos
✗ todo knowledge
```

### Caso B — Fish

Solucionar un problema de Fish.

Esperado:

- solo archivos Fish relevantes;
- búsqueda selectiva en knowledge;
- no cargar configuración de monitores;
- no cargar bootstrap salvo relación real.

### Caso C — `/solved`

Después de validar una solución:

Esperado:

- usar delta Git;
- inspeccionar cambios relevantes;
- no releer todo el repositorio;
- no recorrer knowledge completo;
- generar/actualizar la entrada necesaria;
- ejecutar verificaciones enfocadas;
- commit limpio.

### Caso D — bootstrap

Reportar un problema específicamente en `bootstrap.sh`.

Esperado:

- ahora sí debe leer bootstrap;
- puede leer package manifests relacionados;
- puede consultar knowledge relacionado;
- no debe cargar componentes no involucrados.

### Caso E — rollback

Solicitar rollback de Fish.

Esperado:

- leer/usar mecanismo de rollback;
- historial Git de Fish;
- configuración Fish;
- no cargar componentes ajenos.

---

## 23. Prueba de regresión

No romper:

- `/solved`;
- chezmoi;
- bootstrap;
- rollback;
- verify;
- perfiles;
- commits;
- knowledge existente.

La optimización debe cambiar **qué contexto se consulta y cuándo**, no rediseñar el funcionamiento general.

---

## 24. Orden de implementación

Seguir este orden.

### Paso 1

Auditar comportamiento actual e identificar exactamente qué instrucciones provocan:

- lectura completa de `knowledge/`;
- lectura automática de `bootstrap.sh`;
- lectura innecesaria de scripts;
- escaneo completo del repositorio.

No asumir.

### Paso 2

Modificar `AGENTS.md` con context discipline.

### Paso 3

Ajustar `/solved` para usar session/delta context.

### Paso 4

Ajustar skills solamente si actualmente fuerzan carga innecesaria.

### Paso 5

Agregar metadata ligera a nuevas entradas knowledge si aporta valor.

No migrar masivamente el histórico salvo que sea trivial.

### Paso 6

Ejecutar casos de aceptación.

---

## 25. Regla contra sobre-ingeniería

Antes de crear cualquier archivo, script, comando o dependencia nueva, comprobar:

```text
¿Esto es necesario para evitar lecturas irrelevantes?
```

Si la respuesta es no:

> No crearlo.

En particular, no solucionar este problema introduciendo un sistema de memoria o retrieval más complejo que el propio problema.

---

## 26. Resultado esperado

Después de esta optimización:

```text
ANTES

OpenCode
↓
lee AGENTS
↓
lee knowledge/*
↓
lee bootstrap
↓
lee scripts
↓
lee múltiples configs
↓
resuelve
```

Debe convertirse en:

```text
DESPUÉS

OpenCode
↓
contexto mínimo
↓
identifica tarea
↓
lee config relevante
↓
rg knowledge si hace falta
↓
lee coincidencias relevantes
↓
resuelve
```

Y `/solved`:

```text
ANTES

/solved
↓
relee arquitectura/repositorio
↓
procesa
```

debe convertirse en:

```text
DESPUÉS

/solved
↓
session context
+
git/chezmoi delta
↓
consolida
↓
verify relevante
↓
knowledge
↓
commit
```

---

## 27. Instrucción final para OpenCode

Implementa esta optimización como un cambio pequeño sobre el proyecto existente.

Primero verifica el comportamiento actual y localiza la causa exacta de las lecturas innecesarias.

No asumas que todos los cambios descritos son necesarios si el repositorio ya implementa alguno correctamente.

Aplica únicamente los ajustes confirmados.

No cambies la arquitectura.

No agregues nuevas dependencias salvo necesidad imprescindible.

No implementes RAG, embeddings, bases de datos, caches, daemons ni indexadores.

Prioriza:

1. menos contexto;
2. menos lecturas;
3. menor consumo de tokens;
4. misma funcionalidad;
5. comportamiento predecible;
6. mantenimiento sencillo.

El resultado debe seguir siendo Omarchy Assistant, no un sistema de gestión de conocimiento.
