# Omarchy Assistant — Especificación inicial v0.1

## 1. Objetivo

Crear un proyecto minimalista para administrar, documentar, versionar y restaurar la configuración personal de estaciones de trabajo basadas en Omarchy.

La interfaz principal para el usuario será OpenCode.

El usuario debe poder abrir un acceso directo, entrar directamente al repositorio del proyecto, iniciar OpenCode, describir un problema o cambio, validar manualmente que la solución funciona y ejecutar `/solved`.

A partir de `/solved`, OpenCode debe encargarse de consolidar la solución validada en el estado reproducible del equipo, documentarla, verificarla y versionarla en Git.

El proyecto NO debe convertirse en un framework, gestor de flota, distribución personalizada ni reemplazo de Omarchy.

---

# 2. Filosofía obligatoria

Aplicar estas reglas en todas las decisiones de diseño:

1. Minimalista.
2. Práctico.
3. Funcional.
4. Determinístico cuando sea razonable.
5. Idempotente en scripts de aplicación/configuración.
6. Fácil de leer por una persona nueva.
7. Fácil de eliminar o reemplazar.
8. Reutilizar herramientas maduras antes de crear abstracciones propias.
9. Evitar dependencias nuevas salvo que resuelvan una necesidad concreta.
10. No implementar funcionalidades hipotéticas "por si acaso".

Regla principal:

> Resolver el problema real con la menor cantidad de piezas posible, sin sacrificar mantenibilidad, reversibilidad ni reproducibilidad.

Si una funcionalidad puede resolverse directamente con Git, chezmoi, Bash/Fish o capacidades existentes de OpenCode, no crear una abstracción adicional.

---

# 3. Herramientas base

Usar únicamente como núcleo:

- Omarchy: sistema base.
- Git: historial, versionado y rollback.
- chezmoi: administración del desired state dentro de `$HOME`.
- OpenCode: interfaz conversacional, diagnóstico y orquestación.
- Markdown: documentación y knowledge base.
- Bash o Fish: únicamente para scripts pequeños cuando sean necesarios.

No agregar herramientas adicionales sin una justificación concreta.

---

# 4. Modelo conceptual

Separar claramente:

## Estado deseado

Responde:

> ¿Cómo debe estar configurado este equipo?

Debe ser reproducible.

Ejemplos:

- `starship.toml`
- configuración de Fish
- Ghostty
- Hyprland
- monitores
- aliases
- scripts personales
- paquetes adicionales
- servicios o ajustes específicos cuando proceda

## Knowledge base

Responde:

> ¿Por qué hicimos este cambio?

Debe conservar:

- problema observado;
- causa;
- solución;
- equipo afectado;
- archivos relevantes;
- comandos útiles;
- procedimiento de rollback cuando aplique;
- fecha;
- referencia al commit Git correspondiente.

La documentación NO es la fuente de verdad del estado.

---

# 5. Arquitectura mínima

El proyecto debe seguir aproximadamente esta estructura:

```text
omarchy-assistant/
├── README.md
├── AGENTS.md
├── bootstrap.sh
│
├── .chezmoiroot
├── home/
│   ├── common/
│   ├── omarchy/
│   ├── profiles/
│   │   ├── desktop/
│   │   ├── laptop/
│   │   └── machines/
│   │       ├── desktop-main/
│   │       └── laptop-main/
│   └── ...
│
├── packages/
│   ├── common.txt
│   ├── desktop.txt
│   ├── laptop.txt
│   └── machines/
│       ├── desktop-main.txt
│       └── laptop-main.txt
│
├── knowledge/
│   ├── solved/
│   └── manual/
│
├── scripts/
│   ├── verify
│   ├── rollback
│   └── doctor
│
└── .opencode/
    ├── commands/
    │   └── solved.md
    └── skills/
        ├── omarchy-maintainer/
        └── workstation-state/
```

La estructura puede ajustarse si chezmoi requiere otra organización interna más natural.

No crear directorios vacíos o capas sin uso real.

---

# 6. Resolución de configuración por perfil

El estado efectivo de una máquina debe componerse conceptualmente así:

```text
common
+
omarchy
+
device-class
+
machine
=
desired state
```

Ejemplo:

```text
common
+
omarchy
+
desktop
+
desktop-main
```

Otro ejemplo:

```text
common
+
omarchy
+
laptop
+
laptop-main
```

## `common`

Configuración compartida entre todos los equipos.

Ejemplos:

- Fish general;
- Starship;
- Git;
- OpenCode;
- aliases;
- scripts personales.

## `omarchy`

Ajustes aplicables específicamente a Omarchy.

No copiar internals completos de Omarchy.

Mantener este proyecto como una capa encima de Omarchy.

## `desktop` / `laptop`

Configuración compartida por clase de dispositivo.

Ejemplo:

- ajustes de batería para laptop;
- paquetes exclusivos de escritorio;
- comportamiento general de pantallas externas.

## `machines/<hostname>`

Configuración estrictamente específica de hardware o del equipo.

Ejemplos:

- layout de monitores;
- escala;
- orientación vertical;
- GPU;
- dispositivos de audio;
- periféricos;
- workspaces ligados a monitores.

---

# 7. Identificación de máquina

La identificación inicial debe basarse en hostname.

Ejemplo:

```text
desktop-main
laptop-main
```

No crear un sistema complejo de fingerprints de hardware en v0.1.

Debe existir una forma sencilla de sobrescribir el perfil manualmente si fuera necesario.

---

# 8. Chezmoi

Chezmoi debe ser el administrador del estado del usuario.

Debe encargarse principalmente de:

- Fish;
- Starship;
- Ghostty;
- Hyprland;
- Waybar;
- Walker;
- Git;
- OpenCode;
- scripts del usuario;
- otros dotfiles relevantes.

No duplicar las capacidades básicas de chezmoi mediante scripts propios.

Cuando sea posible utilizar directamente:

```bash
chezmoi diff
chezmoi apply
chezmoi status
```

en lugar de crear wrappers.

Crear wrappers solo cuando aporten lógica real del proyecto.

---

# 9. Git

Git es el sistema de historial y reversibilidad.

## Reglas

- Commits pequeños.
- Cambios relacionados únicamente.
- Mensajes descriptivos.
- No ejecutar `git add -A` ciegamente durante `/solved`.
- Revisar primero qué cambios pertenecen realmente a la solución.
- No registrar archivos temporales, logs ni secretos.

Formato recomendado:

```text
fix(starship): remove slow custom command
fix(fish): restore valid startup configuration
feat(hypr): add vertical secondary monitor layout
chore(packages): add required desktop utility
```

---

# 10. Known-good state

No crear una base de datos ni un sistema propio de snapshots.

Para v0.1:

- un commit generado después de `/solved` se considera un estado validado;
- Git es la fuente de historial;
- tags pueden utilizarse únicamente para checkpoints importantes.

Ejemplos de checkpoints:

```text
desktop-main-known-good-2026-08-14
laptop-main-known-good-2026-08-14
```

No crear tags para cada cambio pequeño.

---

# 11. Flujo principal con OpenCode

El usuario debe trabajar así:

```text
abrir acceso directo
↓
Ghostty
↓
cd al proyecto
↓
OpenCode
↓
describir problema
↓
OpenCode diagnostica
↓
OpenCode aplica cambios mínimos
↓
usuario prueba
↓
usuario confirma que funciona
↓
/solved
```

OpenCode puede experimentar durante el diagnóstico.

Mientras no exista `/solved`, los cambios NO se consideran estado validado.

---

# 12. Contrato de `/solved`

`/solved` es la operación más importante del proyecto.

Semánticamente significa:

> El usuario ha validado que la solución actual funciona. Consolídala como estado reproducible conocido.

## `/solved` debe:

### 1. Inspeccionar

Revisar:

```bash
git status
git diff
chezmoi status
chezmoi diff
```

y otros comandos mínimos necesarios.

### 2. Determinar qué cambió

Identificar:

- archivos modificados;
- archivos temporales;
- cambios experimentales;
- cambios realmente necesarios para la solución.

No asumir que todo el working tree pertenece a la solución.

### 3. Clasificar el scope

Determinar si el cambio corresponde a:

```text
common
omarchy
desktop
laptop
machine-specific
```

### 4. Actualizar desired state

Capturar únicamente el estado final necesario utilizando chezmoi o los manifiestos correspondientes.

### 5. Registrar paquetes

Si la solución requirió instalar una aplicación necesaria de forma persistente:

- agregarla al manifiesto adecuado;
- evitar duplicados;
- clasificarla en common, device-class o machine.

### 6. Documentar

Crear:

```text
knowledge/solved/YYYY-MM-DD-slug.md
```

Formato mínimo:

```markdown
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

No copiar conversaciones completas.

Documentar solamente conocimiento útil y reutilizable.

### 7. Verificar

Ejecutar las validaciones disponibles.

Si existe un validador nativo de la herramienta, preferirlo.

Ejemplos conceptuales:

```text
Fish -> syntax validation
chezmoi -> diff/status
Hyprland -> validación disponible si existe
scripts -> shell syntax check
```

No inventar validadores ficticios.

### 8. Comprobar idempotencia

Cuando la solución utilice scripts de aplicación:

```text
apply
verify
apply otra vez
verify
```

La segunda ejecución no debe introducir cambios adicionales.

No ejecutar esta secuencia cuando no aporte nada, por ejemplo para un archivo estático administrado directamente por chezmoi.

### 9. Crear commit

Solo si:

- la solución está validada por el usuario;
- el desired state está limpio;
- las verificaciones necesarias pasan.

### 10. Push

Si existe remote configurado y el usuario ha establecido que este repositorio debe sincronizarse automáticamente, hacer push.

Si no existe remote, no fallar por ello.

---

# 13. `/solved` no debe

- hacer `git add -A` sin revisar;
- incluir cambios ajenos;
- crear múltiples capas de abstracción;
- generar scripts para configuraciones que chezmoi puede administrar directamente;
- modificar internals de Omarchy sin necesidad;
- convertir cada solución en una nueva "feature";
- crear agentes adicionales automáticamente;
- instalar dependencias nuevas innecesarias;
- guardar secretos.

---

# 14. Restore vs rollback

Mantener dos conceptos separados.

## Restore

Descarta cambios experimentales aún no consolidados.

Ejemplo conceptual:

```text
restore starship
```

Resultado:

> Starship regresa al último estado registrado.

Inicialmente puede implementarse mediante Git + chezmoi sin crear un sistema propio.

## Rollback

Retrocede un componente o el estado completo a una versión anterior ya registrada.

Debe apoyarse en Git.

Ejemplos conceptuales:

```text
rollback fish
rollback starship
rollback --commit <hash>
```

No implementar una base de datos de versiones.

---

# 15. Rollback por componente

Priorizar rollback focalizado.

Ejemplo:

```text
Fish roto
↓
restaurar archivos administrados de Fish
↓
chezmoi apply
↓
verify
```

No modificar:

- Starship;
- Ghostty;
- Hyprland;
- otros componentes no relacionados.

Para v0.1, puede ser suficiente que OpenCode use Git para encontrar y restaurar los archivos correspondientes.

No construir todavía un registry complejo de componentes.

---

# 16. `bootstrap.sh`

Objetivo:

> Llevar una instalación limpia de Omarchy al desired state registrado para esa máquina.

Debe ser simple e idempotente.

Flujo:

```text
verificar Omarchy
↓
verificar Git
↓
instalar/verificar chezmoi
↓
detectar hostname
↓
resolver perfiles
↓
instalar paquetes declarados
↓
aplicar chezmoi
↓
ejecutar verify
```

No gestionar la instalación completa de Omarchy.

Omarchy debe instalarse por su procedimiento oficial.

---

# 17. Paquetes

Mantener manifiestos sencillos.

Ejemplo:

```text
packages/common.txt
packages/desktop.txt
packages/laptop.txt
packages/machines/desktop-main.txt
```

Formato:

```text
ripgrep
fd
jq
...
```

No construir un package manager propio.

Resolver `pacman`/AUR únicamente si existe una necesidad concreta.

Para v0.1, documentar claramente qué mecanismo se usa.

---

# 18. `scripts/verify`

Debe ser read-only.

No modificar configuración.

Objetivo:

> Determinar si la máquina cumple el estado esperado en las áreas críticas.

Salida simple:

```text
Omarchy Assistant Verify

[PASS] chezmoi
[PASS] fish
[PASS] starship
[PASS] ghostty
[PASS] hyprland
[PASS] packages

State: HEALTHY
```

Si algo falla:

```text
[FAIL] fish syntax
[WARN] untracked local config

State: DEGRADED
```

No construir un framework de health checks.

Implementar solamente verificaciones concretas disponibles.

---

# 19. `scripts/doctor`

Diagnóstico básico del entorno.

Debe mostrar únicamente información útil:

- hostname;
- perfil resuelto;
- Omarchy presente;
- chezmoi;
- Git;
- OpenCode;
- shell;
- estado básico del repo.

No realizar cambios.

---

# 20. Acceso directo

Crear documentación o un script mínimo para permitir iniciar:

```text
Omarchy Assistant
```

Desde el launcher de Omarchy.

Debe:

1. abrir Ghostty;
2. entrar al repositorio;
3. iniciar OpenCode.

No crear una aplicación gráfica.

No crear TUI.

No crear daemon.

---

# 21. Skills iniciales de OpenCode

Crear únicamente dos skills si son realmente necesarios.

## `omarchy-maintainer`

Responsabilidades:

- comprender estructura y convenciones de Omarchy;
- investigar antes de modificar;
- preferir personalizaciones en la capa del usuario;
- evitar editar defaults internos salvo necesidad;
- conocer ubicaciones típicas de:
  - Hyprland;
  - Fish;
  - Starship;
  - Ghostty;
  - Waybar;
  - Walker;
- aplicar cambios mínimos;
- identificar cuándo una modificación podría interferir con actualizaciones upstream.

No incluir documentación masiva copiada.

Mantener instrucciones operativas y concisas.

## `workstation-state`

Responsabilidades:

- distinguir desired state de documentación;
- clasificar cambios por scope;
- utilizar chezmoi correctamente;
- aplicar reglas de `/solved`;
- manejar Git;
- verificar;
- rollback;
- evitar secretos;
- mantener commits atómicos.

---

# 22. AGENTS.md

Debe explicar a cualquier agente:

## Principios

- minimizar cambios;
- no sobre-ingenierizar;
- no instalar herramientas innecesarias;
- respetar Omarchy upstream;
- utilizar chezmoi como source of truth de dotfiles;
- utilizar Git como source of truth del historial;
- trabajar primero en el problema real;
- solo `/solved` consolida el estado.

## Durante una solución

1. investigar;
2. diagnosticar;
3. cambiar lo mínimo;
4. permitir prueba del usuario;
5. esperar validación;
6. consolidar con `/solved`.

## Prohibido

- commits automáticos antes de validación;
- push antes de `/solved`;
- grandes refactors no solicitados;
- cambios fuera del problema;
- guardar credenciales.

---

# 23. Secretos

Nunca almacenar:

- tokens;
- passwords;
- private keys;
- API keys;
- `.env` con secretos;
- credenciales Wi-Fi;
- claves SSH privadas.

Si una configuración necesita secretos:

- referenciar variables de entorno;
- usar un secret manager existente si el usuario ya dispone de uno;
- documentar la dependencia.

No introducir un secret manager en v0.1.

---

# 24. Omarchy upstream

Este proyecto debe ser un overlay.

No debe:

- hacer fork de Omarchy;
- copiar masivamente `~/.local/share/omarchy`;
- congelar internals de Omarchy;
- reemplazar su mecanismo de actualización.

Cuando una personalización requiera cambiar algo administrado por Omarchy, investigar primero si existe un override soportado.

---

# 25. Reinstalación objetivo

La experiencia objetivo:

```text
instalar Omarchy
↓
clonar repo
↓
./bootstrap.sh
↓
verify
↓
equipo restaurado
```

No se exige reproducibilidad binaria exacta de Arch Linux.

Se busca reproducir:

- intención;
- configuración;
- aplicaciones necesarias;
- comportamiento;
- personalización del usuario.

No fijar versiones de cada paquete salvo necesidad explícita.

---

# 26. Alcance v0.1

Implementar únicamente:

- estructura mínima del repositorio;
- integración con chezmoi;
- perfiles:
  - common;
  - omarchy;
  - desktop;
  - laptop;
  - machine-specific;
- identificación por hostname;
- bootstrap;
- verify;
- doctor;
- rollback simple apoyado en Git;
- `/solved`;
- knowledge base;
- Git workflow;
- AGENTS.md;
- README;
- skills mínimas de OpenCode;
- launcher documentado o script mínimo.

---

# 27. Fuera de alcance

NO implementar en v0.1:

- daemon;
- fleet management;
- TUI;
- GUI;
- API;
- servidor web;
- base de datos;
- telemetría;
- dashboards;
- notificaciones;
- auto-healing;
- webhooks;
- plugin system;
- DSL;
- sincronización peer-to-peer;
- gestión remota;
- Ansible;
- Nix/Home Manager;
- contenedores;
- snapshots propios;
- secret manager propio;
- auto-detección compleja de hardware;
- soporte general para cualquier distribución Linux;
- gestión de Omarchy upstream.

---

# 28. Criterios de aceptación v0.1

La implementación inicial está completa cuando se puede demostrar:

## Caso 1 — configuración común

1. modificar `starship.toml`;
2. probar manualmente;
3. ejecutar `/solved`;
4. verificar que:
   - chezmoi contiene el estado;
   - existe documentación;
   - existe commit limpio;
   - `verify` pasa.

## Caso 2 — configuración específica de máquina

1. modificar layout de monitores de `desktop-main`;
2. `/solved`;
3. confirmar que el cambio se clasifica como machine-specific;
4. confirmar que no se aplica a `laptop-main`.

## Caso 3 — restore

1. modificar Fish de forma incorrecta;
2. NO ejecutar `/solved`;
3. restaurar último estado;
4. Fish vuelve a funcionar;
5. no se genera commit.

## Caso 4 — rollback

1. tener dos commits válidos de Starship;
2. restaurar la versión anterior;
3. aplicar;
4. verificar;
5. ningún componente ajeno cambia.

## Caso 5 — reinstalación

Sobre una instalación limpia de Omarchy:

```text
clone
bootstrap
verify
```

Debe reconstruir el estado personal registrado del equipo con intervención manual mínima.

---

# 29. Orden de implementación recomendado

OpenCode debe implementar en este orden:

## Fase 1

- README;
- AGENTS.md;
- estructura;
- chezmoi;
- perfiles;
- detección de hostname.

## Fase 2

- bootstrap;
- verify;
- doctor.

## Fase 3

- `/solved`;
- knowledge template;
- Git workflow.

## Fase 4

- restore/rollback simple;
- validación de casos de aceptación.

No implementar fases futuras.

---

# 30. Regla de parada

Antes de añadir cualquier componente nuevo, preguntar internamente:

> ¿Existe un problema concreto de v0.1 que no pueda resolverse limpiamente con Git + chezmoi + OpenCode + scripts pequeños?

Si la respuesta es NO:

> No añadirlo.

---

# 31. Entregables que OpenCode debe producir

Al finalizar la primera implementación:

```text
README.md
AGENTS.md
bootstrap.sh
chezmoi source state funcional
perfil common
perfil omarchy
perfil desktop
perfil laptop
soporte machine-specific por hostname
scripts/verify
scripts/doctor
scripts/rollback
.opencode/commands/solved.md
skills mínimas necesarias
knowledge/solved/
ejemplo documentado
.gitignore
```

Además:

- ejecutar validaciones;
- revisar que no existan secretos;
- comprobar shell scripts;
- mostrar `git diff`;
- NO hacer refactors adicionales fuera del scope.

---

# 32. Instrucción final para OpenCode

Implementa esta especificación como una v0.1 mínima y funcional.

Prioriza:

1. claridad;
2. menor número de piezas;
3. uso correcto de herramientas existentes;
4. reproducibilidad;
5. reversibilidad;
6. mantenimiento sencillo.

No optimices para una futura plataforma.

No construyas funcionalidades que no estén explícitamente requeridas.

Cuando haya varias soluciones técnicamente válidas, elegir la más simple que mantenga correctamente el desired state y permita rollback.
