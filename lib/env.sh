#!/usr/bin/env bash

log() {
  echo -e "\n▶ $1"
}

require_var() {
  [ -z "${!1:-}" ] && { echo "❌ Missing ENV: $1"; exit 1; }
}

is_bool() {
  [[ "$1" == "true" || "$1" == "false" ]]
}

load_env() {
  [ ! -f .env ] && { echo "❌ .env fehlt"; exit 1; }
  set -a
  source <(grep -Ev '^(#|$)' .env)
  set +a
}

validate_env() {
  require_var BASE_DOMAIN
  require_var DASHBOARD_SUBDOMAIN
  require_var PANGOLIN_SERVER_SECRET
  require_var ADMIN_EMAIL

  for v in REQUIRE_EMAIL_VERIFICATION DISABLE_SIGNUP_WITHOUT_INVITE DISABLE_USER_CREATE_ORG; do
    is_bool "${!v}" || { echo "❌ $v muss true/false sein"; exit 1; }
  done

  [ "${#PANGOLIN_SERVER_SECRET}" -lt 32 ] && {
    echo "❌ PANGOLIN_SERVER_SECRET zu kurz"
    exit 1
  }

  DASHBOARD_HOST="${DASHBOARD_SUBDOMAIN}.${BASE_DOMAIN}"
  DASHBOARD_URL="https://${DASHBOARD_HOST}"
}
