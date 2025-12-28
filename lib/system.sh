#!/usr/bin/env bash

# Logging-Funktion
log() { echo "[LOG] $*"; }

system_prepare() {
  log "System vorbereiten"

  export DEBIAN_FRONTEND=noninteractive
  export NEEDRESTART_MODE=a 

  # update system
  apt-get update
  apt-get full-upgrade -y

  # install required packages
  apt-get install -y locales curl wget gnupg lsb-release unzip htop

  # set timezone and locale
  timedatectl set-timezone Europe/Berlin
  locale-gen de_DE.UTF-8
  update-locale LANG=de_DE.UTF-8

  # install zram
  apt-get install -y zram-tools

  # configure zram
  cat >/etc/default/zramswap <<'EOF'
ALGO=lz4
PERCENT=75
EOF

  # set swappiness und vfs_cache_pressure
  cat >/etc/sysctl.d/99-zram.conf <<'EOF'
vm.swappiness=15
vm.vfs_cache_pressure=50
EOF
  

  # restart zram service and apply sysctl settings
  systemctl daemon-reexec
  systemctl enable zramswap
  systemctl restart zramswap
  sysctl --system
  

  # remove snap
  log "Snap entfernen"
  systemctl stop snapd.service snapd.socket snapd.seeded.service || true
  systemctl disable snapd.service snapd.socket snapd.seeded.service || true
  apt-get purge -y snapd gnome-software-plugin-snap || true
  rm -rf /snap /var/snap /var/lib/snapd /var/cache/snapd || true
  apt-get autoremove -y
  apt-get autoclean -y
  apt-get clean

  # install ufw
  apt-get install -y ufw

  # default policies 
  ufw default deny incoming
  ufw default allow outgoing

  # allow needed ports
  ufw allow ssh                 # SSH für Admin-Zugriff
  ufw allow 80/tcp              # HTTP, Let's Encrypt domain validation
  ufw allow 443/tcp             # HTTPS, Pangolin Web Dashboard / SSL
  ufw allow 51820/udp           # Site Tunnels (Newt → Proxy / Gerbil)
  ufw allow 21820/udp           # Client Tunnels (nur nötig, wenn Clients relayed werden)

  # activate ufw
  ufw --force enable

  # enable fail2ban
  apt-get install -y fail2ban
  systemctl enable fail2ban
  systemctl start fail2ban

  # SSH Passwort-Login deaktivieren
  sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config

  # SSH neu starten, damit die Änderung wirksam wird
  systemctl restart sshd

  # unattended-upgrades 
  apt-get install -y unattended-upgrades
  dpkg-reconfigure --priority=low unattended-upgrades



  # create pangolin config directories
  mkdir -p /opt/config/traefik \
           /opt/config/db \
           /opt/config/letsencrypt \
           /opt/config/logs
}
