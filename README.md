# Linux Secure VM Setup (AIS)

Transforme une VM Debian/Ubuntu **vierge** en machine **opérationnelle** (base, utilisateur, SSH durci, UFW, monitoring).

## 🚀 Installation rapide

```bash
# 1) Cloner
git clone git@github.com:<ton_username>/linux-secure-vm-setup.git
cd linux-secure-vm-setup

# 2) Droits d'exécution
chmod +x setup.sh hardening/ufw_rules.sh monitoring/install_node_exporter.sh

# 3) Lancer (tout en une fois)
sudo ./setup.sh
# ou personnalisé :
# sudo NEW_USER=aisadmin SSH_PORT=22 TIMEZONE=Europe/Paris ./setup.sh all
