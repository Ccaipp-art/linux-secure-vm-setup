---
name: 🔒 Vérification post-install (avancé)
about: Checklist après setup.sh Étape 4 ou all – branche feat/hardening-advanced
title: "[Post-install/ADV] VM durcie sur <Debian/Ubuntu version>"
labels: verification, security, documentation
assignees: ''
---

## 🔎 Contexte
- **VM / OS** :
- **Script lancé** : `./setup.sh 4` ou `./setup.sh all`
- **Vars** : `NEW_USER=...`, `SSH_PORT=...`, `TIMEZONE=...`

## ✅ Checklist (base)
- [ ] **SSH OK (nouvel utilisateur)**
- [ ] **UFW actif + port SSH autorisé**
- [ ] **SSH durci (no root / password selon clés)**
- [ ] **Node Exporter actif**

## ✅ Checklist (sécurité avancée)
- [ ] **fail2ban actif**
  ```bash
  systemctl is-active --quiet fail2ban && echo "OK" || echo "NOK"
  sudo fail2ban-client status sshd
  ```

* [ ] **unattended-upgrades activé**

  ```bash
  systemctl is-enabled --quiet unattended-upgrades && echo "enabled" || echo "disabled"
  ```
* [ ] **auditd actif + règles chargées**

  ```bash
  systemctl is-active --quiet auditd && echo "OK" || echo "NOK"
  sudo auditctl -l | head
  ```
* [ ] **Bannières déployées**

  ```bash
  head -n 1 /etc/issue; head -n 1 /etc/motd
  ```
* [ ] **sysctl appliqué (exemples)**

  ```bash
  sysctl net.ipv4.conf.all.accept_redirects
  sysctl kernel.randomize_va_space
  sysctl kernel.dmesg_restrict
  ```

## 🐞 Problèmes rencontrés (optionnel)

Logs utiles :

```
/var/log/fail2ban.log
/var/log/unattended-upgrades/
journalctl -u ssh -u ufw -u auditd -u fail2ban -u node_exporter --no-pager --since "today"
```
