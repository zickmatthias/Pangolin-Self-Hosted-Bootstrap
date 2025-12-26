#!/usr/bin/env bash

docker_install() {
  if command -v docker &>/dev/null; then
    log "Docker bereits installiert"
    return
  fi

  log "Installiere Docker"
  curl -fsSL https://get.docker.com | sh
  systemctl enable docker
  systemctl start docker
}
