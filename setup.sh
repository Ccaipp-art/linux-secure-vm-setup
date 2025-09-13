#!/usr/bin/env bash
# Setup AIS - VM Linux opérationnelle (Debian/Ubuntu)
# Usage le plus simple : sudo ./setup.sh        (enchaîne tout)
# Usage avancé : sudo NEW_USER=aisadmin SSH_PORT=22 ./setup.sh all

set -Eeuo pipefail

# ---------- Utils ----------
log(){ printf "\n[%s] %s\n" "$(date +'%F %T')" "$*"; }
require_root(){ [[ $EUID -eq 0 ]] || { echo "❌ Lance avec sudo/root"; exit 1; }; }
check_apt(){ command -v apt-get >/dev/null || { echo "❌ apt-get introuvable (Debian/Ubuntu attendu)"; exit 1; }; }

# Options personnalisables (surchargées par variables d'env)
: "${NEW_USER:=aisadmin}"
: "${SSH_PORT:=22}"
: "${TIMEZONE:=Europe/Paris}"

authorized_keys_has_key(){
  local f="$1"
  [[ -s "$f" ]] && grep -E -q 'ssh-(rsa|ed25519)|ecdsa-' "$f"
}

# ---------- Étape 1 : base système ----------
phase_1_basics() {
  export DEBIAN_FRONTEND=noninteractive

  log "Mise à jour des index APT"
  apt-get update -y

  log "Mise à niveau du système"
  apt-get upgrade -y

  log "Outils de base"
  apt-get install -y --no-install-recommends \
    ca-certificates curl wget gnupg lsb-release \
    git vim nano htop tree zip unzip tar rsync jq \
    net-tools iproute2 dnsutils openssh-client openssh-server \
    software-properties-common tmux

  log "Fuseau horaire & NTP"
  timedatectl set-timezone "$TIMEZONE" || true
  timedatectl set-ntp true || true

  log "Infos rapides"
  lsb_release -a || true
  uname -r || true
  log "✅ Étape 1 OK"
}

# ---------- Étape 2 : utilisateur + SSH ----------
phase_2_user_ssh() {
  log "Création utilisateur '${NEW_USER}' + durcissement SSH"

  # 1) Créer l'utilisateur si besoin
  if ! id "$NEW_USER" >/dev/null 2>&1; then
    adduser --disabled-password --gecos "" "$NEW_USER"
    usermod -aG sudo "$NEW_USER"
  else
    log "Utilisateur déjà présent"
  fi

  # 2) Préparer ~/.ssh
  install -d -m 700 "/home/${NEW_USER}/.ssh"
  touch "/home/${NEW_USER}/.ssh/authorized_keys"
  chown -R "${NEW_USER}:${NEW_USER}" "/home/${NEW_USER}/.ssh"
  chmod 600 "/home/${NEW_USER}/.ssh/authorized_keys"

  # Option pratique : si root possède des clés, on les copie
  if [[ -f /root/.ssh/authorized_keys ]]; then
    log "Copie des clés root vers ${NEW_USER} (si présentes)"
    cat /root/.ssh/authorized_keys >> "/home/${NEW_USER}/.ssh/authorized_keys" || true
    sort -u "/home/${NEW_USER}/.ssh/authorized_keys" -o "/home/${NEW_USER}/.ssh/authorized_keys"
  fi

  # 3) Déployer sshd_config sécurisé (si présent dans le repo)
  if [[ -f "./hardening/ssh_config" ]]; then
    cp -a /etc/ssh/sshd_config "/etc/ssh/sshd_config.bak.$(date +%s)" || true
    install -m 644 "./hardening/ssh_config" /etc/ssh/sshd_config
  fi

  # Appliquer/forcer le port voulu
  if grep -q '^[# ]*Port ' /etc/ssh/sshd_config; then
    sed -i "s/^[# ]*Port .*/Port ${SSH_PORT}/" /etc/ssh/sshd_config
  else
    echo "Port ${SSH_PORT}" >> /etc/ssh/sshd_config
  fi

  # ⚠️ Ne désactive l'auth par mot de passe que si une clé est présente
  if authorized_keys_has_key "/home/${NEW_USER}/.ssh/authorized_keys"; then
    sed -i 's/^[# ]*PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config
    sed -i 's/^[# ]*PubkeyAuthentication .*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
    sed -i 's/^[# ]*PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config
    log "Auth par mot de passe désactivée (clé détectée)."
  else
    sed -i 's/^[# ]*PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sed -i 's/^[# ]*PubkeyAuthentication .*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
    sed -i 's/^[# ]*PermitRootLogin .*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
    log "⚠️ Aucune clé détectée pour ${NEW_USER} → PasswordAuthentication laissé à YES pour éviter le lockout."
    log "   Ajoute une clé dans /home/${NEW_USER}/.ssh/authorized_keys puis repasse à no."
  fi

  systemctl restart ssh
  log "✅ Étape 2 OK — connexion: ssh ${NEW_USER}@<IP_VM> -p ${SSH_PORT}"
}

# ---------- Étape 3 : UFW ----------
phase_3_ufw() {
  log "Pare-feu UFW"
  apt-get install -y --no-install-recommends ufw

  if [[ -x "./hardening/ufw_rules.sh" ]]; then
    SSH_PORT="${SSH_PORT}" ./hardening/ufw_rules.sh
  else
    ufw --force reset
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow "${SSH_PORT}"/tcp
    ufw --force enable
  fi

  ufw status verbose || true
  log "✅ Étape 3 OK"
}

# ---------- Étape 5 : Monitoring ----------
phase_5_monitoring() {
  log "Installation Node Exporter (monitoring)"
  if [[ -x "./monitoring/install_node_exporter.sh" ]]; then
    ./monitoring/install_node_exporter.sh
  else
    log "Script monitoring manquant — étape sautée."
  fi
  log "✅ Étape 5 OK"
}

# ---------- Orchestrateur ----------
main(){
  require_root
  check_apt

  local cmd="${1:-all}"
  case "$cmd" in
    1) phase_1_basics ;;
    2) phase_2_user_ssh ;;
    3) phase_3_ufw ;;
    5) phase_5_monitoring ;;
    all)
      phase_1_basics
      phase_2_user_ssh
      phase_3_ufw
      phase_5_monitoring
      ;;
    *)
      echo "Usage:"
      echo "  sudo ./setup.sh            # tout (1+2+3+5)"
      echo "  sudo ./setup.sh 1|2|3|5    # phase isolée"
      echo "  sudo NEW_USER=alice SSH_PORT=22 ./setup.sh all"
      exit 2
      ;;
  esac
}

main "$@"
