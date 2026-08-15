#!/usr/bin/env bash
# bootstrap.sh — Lleva una instalación limpia de Omarchy al desired state.
# Idempotente: puede ejecutarse varias veces con el mismo resultado.
#
# Uso:
#   ./bootstrap.sh [--profile NOMBRE] [--class desktop|laptop]
#
#   --profile NOMBRE        Perfil de máquina; sobrescribe el hostname.
#   --class desktop|laptop  Clase de dispositivo; sobrescribe el archivo
#                           home/profiles/machines/<perfil>/dot_config/omarchy-assistant/class.
#
# Variables de entorno:
#   OMARCHY_PROFILE         Equivale a --profile NOMBRE.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'EOF'
Uso:
  ./bootstrap.sh [--profile NOMBRE] [--class desktop|laptop]

Opciones:
  --profile NOMBRE         Perfil de máquina; sobrescribe el hostname.
  --class desktop|laptop   Clase de dispositivo; sobrescribe el archivo
                           home/profiles/machines/<perfil>/dot_config/omarchy-assistant/class.
  --help                   Muestra esta ayuda.

Variables de entorno:
  OMARCHY_PROFILE          Equivale a --profile NOMBRE.

Flujo: verificar Omarchy -> verificar git -> instalar/verificar chezmoi ->
resolver perfil/clase -> instalar paquetes declarados -> aplicar capas de
chezmoi en orden -> ejecutar scripts/verify.
EOF
}

# --- Parseo de argumentos ---
PROFILE_ARG=""
CLASS_ARG=""
while [ $# -gt 0 ]; do
  case "$1" in
    --profile) PROFILE_ARG="${2:-}"; shift 2 2>/dev/null || true ;;
    --class) CLASS_ARG="${2:-}"; shift 2 2>/dev/null || true ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Opción desconocida: $1" >&2; usage >&2; exit 1 ;;
  esac
done

banner() { printf '\n==== %s ====\n' "$1"; }

banner "Verificar Omarchy"
if grep -qi omarchy /etc/os-release 2>/dev/null; then
  echo "[PASS] Omarchy detectado"
else
  echo "[WARN] no se detectó Omarchy, se continúa"
fi

banner "Verificar git"
if ! command -v git >/dev/null 2>&1; then
  echo "Error: git no está instalado; el repositorio lo requiere." >&2
  exit 1
fi
echo "[PASS] $(git --version)"

banner "Instalar/verificar chezmoi"
if ! command -v chezmoi >/dev/null 2>&1; then
  echo "chezmoi no está instalado; intentando instalarlo con pacman..."
  if [ "$(id -u)" -eq 0 ]; then
    pacman -S --needed chezmoi
  elif command -v sudo >/dev/null 2>&1; then
    sudo pacman -S --needed chezmoi
  else
    echo "Error: se necesita root o sudo para instalar chezmoi." >&2
    exit 1
  fi
fi
if command -v chezmoi >/dev/null 2>&1; then
  echo "[PASS] chezmoi $(chezmoi --version)"
else
  echo "Error: chezmoi no quedó instalado." >&2
  exit 1
fi

banner "Resolver perfil y clase"
# 1. Perfil: OMARCHY_PROFILE -> --profile -> hostname.
profile="${OMARCHY_PROFILE:-}"
if [ -n "$PROFILE_ARG" ]; then profile="$PROFILE_ARG"; fi
if [ -z "$profile" ]; then profile="$(hostname)"; fi

machine_dir="$REPO_DIR/home/profiles/machines/$profile"

# 2. Clase: archivo "class" de la capa machine -> --class -> error explicativo.
class=""
if [ -f "$machine_dir/dot_config/omarchy-assistant/class" ]; then
  class="$(sed -n '1{s/^[[:space:]]*//;s/[[:space:]]*$//;p}' "$machine_dir/dot_config/omarchy-assistant/class")"
fi
if [ -z "$class" ]; then class="$CLASS_ARG"; fi
if [ -z "$class" ]; then
  echo "Error: no se pudo determinar la clase de dispositivo para el perfil «$profile»." >&2
  echo "  Opción 1: crea $machine_dir/dot_config/omarchy-assistant/class con una línea «desktop» o «laptop»." >&2
  echo "  Opción 2: pasa --class desktop|laptop." >&2
  exit 1
fi

# 3. Capa machine opcional.
if [ -d "$machine_dir" ]; then
  echo "[PASS] perfil: $profile (clase $class, con capa machine)"
else
  echo "[WARN] no hay capa específica para esta máquina ($profile); se usan common+omarchy+$class"
fi

# 4. Capas en orden: common -> omarchy -> clase -> machine (la posterior sobrescribe).
layers=("common" "omarchy" "profiles/$class")
if [ -d "$machine_dir" ]; then layers+=("profiles/machines/$profile"); fi
echo "Capas: ${layers[*]}"

banner "Instalar paquetes declarados"
if ! command -v pacman >/dev/null 2>&1; then
  echo "[WARN] pacman no disponible; se omiten los paquetes."
else
  pkg_files=("$REPO_DIR/packages/common.txt" "$REPO_DIR/packages/$class.txt")
  if [ -f "$REPO_DIR/packages/machines/$profile.txt" ]; then
    pkg_files+=("$REPO_DIR/packages/machines/$profile.txt")
  fi
  # Una línea por paquete, comentarios con #, sin duplicados (sort -u).
  mapfile -t pkg_list < <(sed -e 's/#.*$//' -e '/^[[:space:]]*$/d' "${pkg_files[@]}" 2>/dev/null | sort -u)
  if [ "${#pkg_list[@]}" -eq 0 ]; then
    echo "[PASS] sin paquetes declarados"
  else
    echo "Paquetes: ${pkg_list[*]}"
    echo "Nota: solo repos oficiales de pacman; AUR está fuera del alcance de v0.1."
    if [ "$(id -u)" -eq 0 ]; then
      pacman -S --needed - < <(printf '%s\n' "${pkg_list[@]}")
    elif command -v sudo >/dev/null 2>&1; then
      sudo pacman -S --needed - < <(printf '%s\n' "${pkg_list[@]}")
    else
      echo "Error: se necesita root o sudo para instalar paquetes." >&2
      exit 1
    fi
    echo "[PASS] paquetes instalados"
  fi
fi

banner "Aplicar capas de chezmoi"
for layer in "${layers[@]}"; do
  echo "Aplicando capa: $layer"
  chezmoi apply --source "$REPO_DIR/home/$layer"
done

banner "Verificar"
# Pasa el perfil y la clase resueltos para que verify use la misma resolución
# y propaga su código de salida (0 = HEALTHY, 1 = DEGRADED).
"$REPO_DIR/scripts/verify" --profile "$profile" --class "$class"
