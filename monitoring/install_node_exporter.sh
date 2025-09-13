#!/usr/bin/env bash
# Installation Prometheus Node Exporter

set -Eeuo pipefail

NODE_EXPORTER_VERSION="1.8.1"

log() { echo "[Node Exporter] $*"; }

log "Téléchargement de Node Exporter v${NODE_EXPORTER_VERSION}"
cd /tmp
curl -LO https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz

log "Extraction"
tar xvf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
sudo mv node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter /usr/local/bin/

log "Création utilisateur node_exporter"
sudo useradd -rs /bin/false node_exporter || true

log "Création du service systemd"
cat <<EOF | sudo tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Prometheus Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

log "Activation et démarrage"
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

log "✅ Node Exporter installé (http://localhost:9100/metrics)"
