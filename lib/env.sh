#!/usr/bin/env bash

# --- Logging ---
log() {
  echo -e "\n▶ $1"
}

# --- Variable prüfen ---
require_var() {
  if [ -z "${!1:-}" ]; then
    echo "❌ Missing ENV: $1"
    exit 1
  fi
}

# --- Boolean prüfen ---
is_bool() {
  [[ "$1" == "true" || "$1" == "false" ]]
}

# --- .env laden ---
load_env() {
  # Absoluter Pfad zum Script
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  # .env ist im Projektroot (ein Verzeichnis über lib/)
  ENV_FILE="$(dirname "$SCRIPT_DIR")/.env"

  if [ ! -f "$ENV_FILE" ]; then
      echo "❌ .env fehlt im Verzeichnis $(dirname "$SCRIPT_DIR")"
      exit 1
  fi

  # Alle Variablen exportieren (Kommentare und leere Zeilen ignorieren)
  while IFS='=' read -r key value; do
    # Ignoriere Zeilen mit # am Anfang
    [[ "$key" =~ ^#.* ]] && continue
    # Ignoriere leere Zeilen
    [[ -z "$key" ]] && continue
    # Exportiere Variable
    export $key="$value"
  done < <(grep -v '^[[:space:]]*$' "$ENV_FILE" | grep -v '^[[:space:]]*#')

  log ".env erfolgreich geladen"
}

# --- Variablen validieren ---
validate_env() {
  require_var BASE_DOMAIN
  require_var DASHBOARD_SUBDOMAIN
  require_var PANGOLIN_SERVER_SECRET
  require_var ADMIN_EMAIL

  for v in REQUIRE_EMAIL_VERIFICATION DISABLE_SIGNUP_WITHOUT_INVITE DISABLE_USER_CREATE_ORG; do
    is_bool "${!v}" || { echo "❌ $v muss true/false sein"; exit 1; }
  done

  [ "${#PANGOLIN_SERVER_SECRET}" -lt 32 ] && {
    echo "❌ PANGOLIN_SERVER_SECRET muss mindestens 32 Zeichen lang sein"
    exit 1
  }

  DASHBOARD_HOST="${DASHBOARD_SUBDOMAIN}.${BASE_DOMAIN}"
  DASHBOARD_URL="https://${DASHBOARD_HOST}"

  log "ENV-Validierung abgeschlossen"
}
