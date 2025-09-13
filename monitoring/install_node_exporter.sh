#!/usr/bin/env bash
set -Eeuo pipefail

NODE_EXPORTER_VERSION="1.8.1"
log(){ echo "[Node Exporter] $*"; }

log "Téléchargement v${NODE_EXPORTER_VERSION}"
cd /tmp
curl -fsSLO "https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"

log "Extraction"
tar xzf "node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"
mv "node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter" /usr/local/bin/

log "Utilisateur système"
id -u node_exporter >/dev/null 2>&1 || useradd -rs /bin/false node_exporter

log "Service systemd"
cat >/etc/systemd/system/node_exporter.service <<'EOF'
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

log "Enable + start"
systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter

log "✅ OK — métriques sur http://localhost:9100/metrics"
