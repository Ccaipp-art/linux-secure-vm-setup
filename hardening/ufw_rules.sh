#!/usr/bin/env bash
set -Eeuo pipefail
: "${SSH_PORT:=22}"
log(){ echo "[UFW] $*"; }

log "Reset des règles"
ufw --force reset

log "Politiques par défaut"
ufw default deny incoming
ufw default allow outgoing

log "Autoriser SSH ${SSH_PORT}/tcp"
ufw allow "${SSH_PORT}"/tcp

# (décommente au besoin)
# ufw allow 80/tcp
# ufw allow 443/tcp

log "Activer UFW"
ufw --force enable
log "✅ UFW actif"
