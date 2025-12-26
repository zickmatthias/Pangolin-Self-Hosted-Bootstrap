#!/usr/bin/env bash

system_prepare() {
  log "System vorbereiten"

  export DEBIAN_FRONTEND=noninteractive
  apt-get update -y
  apt-get upgrade -y

  mkdir -p \
    config/traefik \
    config/db \
    config/letsencrypt \
    config/logs
}
