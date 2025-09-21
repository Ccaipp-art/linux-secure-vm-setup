#!/usr/bin/env bash
# Configuration UFW basique

set -Eeuo pipefail

log() { echo "[UFW] $*"; }

log "Réinitialisation des règles"
ufw --force reset

log "Politique par défaut : deny incoming / allow outgoing"
ufw default deny incoming
ufw default allow outgoing

log "Ouverture SSH (port 22)"
ufw allow $(SSH_PORT)

# Exemple si tu veux autoriser HTTP/HTTPS plus tard :
# ufw allow 80/tcp
# ufw allow 443/tcp

log "Activation du firewall"
ufw --force enable

log "✅ UFW configuré"
