---
name: ✅ Vérification post-install (base)
about: Checklist à cocher après avoir lancé setup.sh (all ou étapes) – branche main
title: "[Post-install] VM validée sur <Debian/Ubuntu version>"
labels: verification, documentation
assignees: ''
---

## 🔎 Contexte
- **VM / OS** :
- **Script lancé** : `./setup.sh all` ou étapes (préciser)
- **Vars** : `NEW_USER=...`, `SSH_PORT=...`, `TIMEZONE=...`

---

## ✅ Checklist (base)

- [ ] **SSH accessible avec le nouvel utilisateur**
  ```bash
  ssh <NEW_USER>@<IP_VM> -p <SSH_PORT>
  ```

* [ ] **UFW actif + port SSH autorisé**

  ```bash
  sudo ufw status verbose
  ```

* [ ] **SSH durci (pas de root / mot de passe off si clés)**

  ```bash
  sshd -T | egrep 'permitrootlogin|passwordauthentication|port'
  ```

* [ ] **Node Exporter en service**

  ```bash
  systemctl is-active --quiet node_exporter && echo "OK" || echo "NOK"
  curl -s http://localhost:9100/metrics | head -n 3
  ```

---

## 🐞 Problèmes rencontrés (optionnel)

Décrivez ici vos soucis. Logs utiles :

```bash
journalctl -u ssh -u ufw -u node_exporter --no-pager --since "today"
```

````

📂 `.github/ISSUE_TEMPLATE/config.yml` *(optionnel mais conseillé)*

```yml
blank_issues_enabled: false
```
