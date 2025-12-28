#!/usr/bin/env bash
set -Eeuo pipefail

# Lade lib/env.sh
source lib/env.sh

# Lade ENV
load_env



# Validieren
validate_env

# Prüfen der abgeleiteten Werte
echo "BASE_DOMAIN = $BASE_DOMAIN"
echo "DASHBOARD_SUBDOMAIN = $DASHBOARD_SUBDOMAIN"
echo "DASHBOARD_HOST = $DASHBOARD_HOST"
echo "DASHBOARD_URL = $DASHBOARD_URL"
echo "PANGOLIN_SERVER_SECRET = ${PANGOLIN_SERVER_SECRET:0:4}..."  # nur Anfang anzeigen
echo "ADMIN_EMAIL = $ADMIN_EMAIL"
