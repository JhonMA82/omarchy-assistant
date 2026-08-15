# Omarchy Assistant

Administra, documenta, versiona y restaura la configuración personal de estaciones de trabajo basadas en Omarchy. La interfaz principal es OpenCode: describes un problema o cambio, pruebas manualmente y, cuando la solución funciona, ejecutas `/solved` para consolidarla como estado reproducible.

> **Regla principal:** resolver el problema real con la menor cantidad de piezas posible, sin sacrificar mantenibilidad, reversibilidad ni reproducibilidad.

## Filosofía (resumen)

1. Minimalista
2. Práctico
3. Funcional
4. Determinístico cuando sea razonable
5. Idempotente en scripts de aplicación y configuración
6. Fácil de leer por una persona nueva
7. Fácil de eliminar o reemplazar
8. Reutilizar herramientas maduras antes de crear abstracciones propias
9. Evitar dependencias nuevas salvo que resuelvan una necesidad concreta
10. No implementar funcionalidades hipotéticas "por si acaso"

## Requisitos

- **Omarchy v4 (Quattro) o posterior** instalado por su procedimiento oficial (este proyecto no gestiona su instalación).
- **Git** (el repositorio lo requiere).
- **chezmoi** (`bootstrap.sh` lo instala si falta).
- **OpenCode** como interfaz principal.

## Estructura

```text
omarchy-assistant/
├── README.md
├── AGENTS.md
├── bootstrap.sh
├── .chezmoiroot
├── .gitignore
├── OMARCHY_ASSISTANT_INITIAL_SPEC.md
├── home/
│   ├── common/                     # capa común (todos los equipos)
│   ├── omarchy/                    # capa de ajustes de Omarchy
│   └── profiles/
│       ├── desktop/                # clase de dispositivo: escritorio
│       ├── laptop/                 # clase de dispositivo: portátil
│       └── machines/               # una capa por hostname
│           ├── desktop-main/
│           └── laptop-main/
├── packages/                       # manifiestos de paquetes (pacman)
│   ├── common.txt
│   ├── desktop.txt
│   ├── laptop.txt
│   └── machines/
│       ├── desktop-main.txt
│       └── laptop-main.txt
├── knowledge/
│   ├── solved/                     # soluciones validadas (formato fijo)
│   └── manual/                     # notas sin formato estructurado
├── scripts/
│   ├── verify                      # chequeo de solo lectura
│   ├── doctor                      # diagnóstico del entorno
│   └── rollback                    # retroceso por componente
└── .opencode/
    ├── commands/solved.md          # comando /solved
    └── skills/
        ├── omarchy-maintainer/
        └── workstation-state/
```

## Estado deseado por perfil

Cada máquina compone su estado así:

```text
common + omarchy + device-class + machine = desired state
```

| Capa | Directorio | ¿Cuándo aplica? |
|---|---|---|
| `common` | `home/common/` | todos los equipos |
| `omarchy` | `home/omarchy/` | ajustes específicos de Omarchy |
| `desktop` / `laptop` | `home/profiles/desktop/`, `home/profiles/laptop/` | clase de dispositivo |
| `machine` | `home/profiles/machines/<hostname>/` | un equipo concreto |

**Identificación:** por hostname (por ejemplo `desktop-main`). Para sobrescribirla se usa la variable de entorno `OMARCHY_PROFILE` o el flag `--profile NOMBRE`. La clase se lee del archivo `class` de la capa de máquina o se fuerza con `--class desktop|laptop`. Si no existe capa para esa máquina, se usa `common + omarchy + clase` y se avisa.

## Capas de chezmoi (orden obligatorio)

Cada capa es un directorio fuente independiente de chezmoi. Se aplican siempre en este orden; la capa posterior sobrescribe a la anterior:

```bash
chezmoi apply --source "<repo>/home/common"
chezmoi apply --source "<repo>/home/omarchy"
chezmoi apply --source "<repo>/home/profiles/desktop"           # o laptop, según la clase
chezmoi apply --source "<repo>/home/profiles/machines/<perfil>" # si existe la capa
```

Para inspeccionar: `chezmoi --source "<repo>/home/<capa>" status` y `chezmoi --source "<repo>/home/<capa>" diff`.

La única sobrescritura entre capas del mismo archivo es `dot_config/omarchy-assistant/profile` (demuestra el mecanismo de capas). `.chezmoiroot` apunta a `home/common` como capa base para `chezmoi init <repo>`.

## Flujo diario

```text
acceso directo → Ghostty → cd al repositorio → OpenCode → describir problema
→ OpenCode diagnostica → aplica cambios mínimos → pruebas → confirmas que funciona → /solved
```

Mientras no ejecutes `/solved`, los cambios NO son estado validado. Puedes crear un acceso directo de escritorio que abra Ghostty, entre al repositorio y ejecute `opencode`.

`/solved` consolida: inspecciona, clasifica el scope, actualiza el desired state con chezmoi, registra paquetes, documenta en `knowledge/solved/`, verifica, hace commit pequeño y push si hay remote.

## Bootstrap

```bash
./bootstrap.sh                        # perfil = hostname; clase desde la capa machine
./bootstrap.sh --profile desktop-main --class desktop
OMARCHY_PROFILE=desktop-main ./bootstrap.sh
```

Opciones: `--profile NOMBRE` (sobrescribe el hostname) y `--class desktop|laptop` (sobrescribe el archivo `class`).

**Experiencia de reinstalación:** instalar Omarchy → clonar el repositorio → `./bootstrap.sh` → `scripts/verify` → equipo restaurado. Se reproduce intención, configuración, aplicaciones y personalización; no se busca reproducibilidad binaria exacta ni fijar versiones.

## Paquetes

Manifiestos en `packages/`: `common.txt`, `desktop.txt`, `laptop.txt` y `machines/<perfil>.txt`.

- Solo repos oficiales de pacman; instalación con `sudo pacman -S --needed`.
- **AUR queda fuera del alcance de v0.1.**
- Formato: un paquete por línea; comentarios con `#`; sin duplicados (se eliminan con `sort -u` al fusionar).
- Los manifiestos de clase y máquina se mantienen vacíos hasta que exista una necesidad real.

## Restore vs rollback

**Restore** descarta cambios experimentales aún no consolidados:

```bash
git checkout -- <rutas>                    # descarta ediciones locales
chezmoi apply --source "<repo>/home/<capa>" # reaplica cada capa en orden
```

**Rollback** retrocede un componente a una versión ya registrada en Git:

```bash
scripts/rollback <componente>
scripts/rollback --commit <hash> <componente>
scripts/rollback --dry-run <componente>
```

Componentes: `fish starship ghostty hypr quickshell git opencode scripts`. El rollback nunca toca componentes ajenos al indicado.

## Verify y doctor

- `scripts/verify`: solo lectura; imprime una línea `[PASS]`/`[FAIL]`/`[WARN]` por chequeo y termina con `State: HEALTHY` (exit 0) o `State: DEGRADED` (exit 1). Cualquier `[FAIL]` degrada el estado; los `[WARN]` por sí solos no.
- `scripts/doctor`: diagnóstico del entorno (hostname, perfil, capas, versiones, estado del repo). Solo informa; nunca falla.

## Secretos

Nunca almacenar tokens, passwords, private keys, API keys, `.env` con secretos, credenciales Wi-Fi ni claves SSH privadas. Si una configuración los necesita, referencia variables de entorno o un secret manager existente y documenta la dependencia.

## Fuera de alcance (v0.1)

daemon, fleet management, TUI, GUI, API, servidor web, base de datos, telemetría, dashboards, notificaciones, auto-healing, webhooks, plugin system, DSL, sincronización P2P, gestión remota, Ansible, Nix/Home Manager, contenedores, snapshots propios, secret manager propio, auto-detección compleja de hardware, soporte de otras distribuciones, gestión de Omarchy upstream.

## Especificación

La especificación completa está en [`OMARCHY_ASSISTANT_INITIAL_SPEC.md`](OMARCHY_ASSISTANT_INITIAL_SPEC.md).
