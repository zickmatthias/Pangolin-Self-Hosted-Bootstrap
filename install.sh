#!/usr/bin/env bash
set -Eeuo pipefail
trap 'echo "❌ Fehler in Zeile $LINENO"' ERR

source lib/env.sh
source lib/system.sh
source lib/docker.sh
source lib/generate.sh
source lib/pangolin.sh

load_env
validate_env

system_prepare
docker_install
generate_all_configs
pangolin_up

log "✅ Installation abgeschlossen"
