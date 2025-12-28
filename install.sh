#!/usr/bin/env bash
set -Eeuo pipefail
trap 'echo "❌ Fehler in Zeile $LINENO"' ERR
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# --- Logs ---
mkdir -p /var/log/setup
exec > >(tee -i /var/log/setup/main.log) 2>&1

# --- Root check ---
if [[ $EUID -ne 0 ]]; then
    echo "Dieses Script muss als root ausgeführt werden." >&2
    exit 1
fi

# --- Logging-Funktion ---
log() { echo "[LOG] $*"; }

# --- Deine Quellen ---
source lib/env.sh
source lib/system.sh
source lib/docker.sh
source lib/generate.sh
source lib/pangolin.sh

load_env
validate_env

system_prepare
#docker_install
generate_all_configs
#pangolin_up

log "✅ Installation abgeschlossen"
