#!/usr/bin/env bash
# Étape 1 : mise à jour système + outils de base
# Usage : sudo bash setup.sh 1    (ou simplement sudo ./setup.sh 1)

set -Eeuo pipefail

require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    echo "❌ Ce script doit être lancé avec sudo/root."
    exit 1
  fi
}

log() { printf "\n[%s] %s\n" "$(date +'%F %T')" "$*"; }

check_apt() {
  if ! command -v apt-get >/dev/null 2>&1; then
    echo "❌ Distribution non supportée (attendu: Debian/Ubuntu avec apt-get)."
    exit 1
  fi
}

phase_1_basics() {
  export DEBIAN_FRONTEND=noninteractive

  log "Mise à jour des index APT"
  apt-get update -y

  log "Mise à niveau du système (packages)"
  apt-get upgrade -y

  log "Installation des outils de base"
  apt-get install -y --no-install-recommends \
    ca-certificates curl wget gnupg lsb-release \
    git vim nano htop tree zip unzip tar rsync jq \
    net-tools iproute2 dnsutils openssh-client \
    software-properties-common tmux

  log "Configuration de l'heure (Europe/Paris) & NTP"
  timedatectl set-timezone Europe/Paris || true
  timedatectl set-ntp true || true

  log "Infos système rapides"
  lsb_release -a || true
  uname -r || true

  log "✅ Étape 1 terminée."
  echo "Prochaines étapes (seront ajoutées dans ce script plus tard) :"
  echo " 2) Utilisateur + SSH hardening"
  echo " 3) UFW (pare-feu)"
  echo " 4) Sécurité (fail2ban, unattended-upgrades, logwatch)"
  echo " 5) Monitoring (node_exporter)"
}

main() {
  require_root
  check_apt

  PHASE="${1:-1}"

  case "${PHASE}" in
    1) phase_1_basics ;;
    *) echo "Usage: sudo ./setup.sh 1   # (seule l'étape 1 est dispo pour l'instant)"; exit 2 ;;
  esac
}

main "$@"
