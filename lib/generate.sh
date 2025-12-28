#!/usr/bin/env bash

generate_all_configs() {
  generate_docker_compose
  generate_traefik_static
  generate_traefik_dynamic
  generate_pangolin_config
}

generate_docker_compose() {
  log "docker-compose.yml erzeugen"

  cat > /opt/config/docker-compose.yml <<EOF
services:
  pangolin:
    image: fosrl/pangolin:latest
    restart: unless-stopped
    volumes:
      - /opt/config:/app/config

  gerbil:
    image: fosrl/gerbil:latest
    restart: unless-stopped
    depends_on:
      pangolin:
        condition: service_started
    command:
      - --reachableAt=http://gerbil:3004
      - --generateAndSaveKeyTo=/var/config/key
      - --remoteConfig=http://pangolin:3001/api/v1/
    volumes:
      - /opt/config:/var/config
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    ports:
      - 51820:51820/udp
      - 21820:21820/udp
      - 80:80
      - 443:443

  traefik:
    image: traefik:v3.4.0
    network_mode: service:gerbil
    depends_on:
      pangolin:
        condition: service_started
    command:
      - --configFile=/etc/traefik/traefik_config.yml
    volumes:
      - /opt/config/traefik:/etc/traefik:ro
      - /opt/config/letsencrypt:/letsencrypt
EOF
}

generate_traefik_static() {
  log "Traefik static config"

  cat > /opt/config/traefik/traefik_config.yml <<EOF
certificatesResolvers:
  letsencrypt:
    acme:
      httpChallenge:
        entryPoint: web
      email: ${ADMIN_EMAIL}
      storage: /letsencrypt/acme.json

entryPoints:
  web:
    address: ":80"
  websecure:
    address: ":443"
    http:
      tls:
        certResolver: letsencrypt
EOF
}

generate_traefik_dynamic() {
  log "Traefik dynamic config"

  cat > /opt/config/traefik/dynamic_config.yml <<EOF
http:
  routers:
    app:
      rule: "Host(\`${DASHBOARD_HOST}\`)"
      entryPoints: [websecure]
      service: pangolin
      tls:
        certResolver: letsencrypt

  services:
    pangolin:
      loadBalancer:
        servers:
          - url: "http://pangolin:3002"
EOF
}

generate_pangolin_config() {
  log "Pangolin config.yml"

  cat > /opt/config/config.yml <<EOF
app:
  dashboard_url: "${DASHBOARD_URL}"

domains:
  domain1:
    base_domain: "${DASHBOARD_HOST}"
    cert_resolver: "letsencrypt"

server:
  secret: "${PANGOLIN_SERVER_SECRET}"
gerbil:
  base_endpoint: "${DASHBOARD_HOST}"

flags:
  require_email_verification: ${REQUIRE_EMAIL_VERIFICATION}
  disable_signup_without_invite: ${DISABLE_SIGNUP_WITHOUT_INVITE}
  disable_user_create_org: ${DISABLE_USER_CREATE_ORG}
EOF
}
