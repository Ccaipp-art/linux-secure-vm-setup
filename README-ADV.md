# 🔒 Linux Secure VM Setup — Améliorations avancées

Ce document accompagne la branche **feat/hardening-advanced**.  
Ici, nous ajoutons un **niveau de sécurité supplémentaire** à la VM avec :  
- `fail2ban` → bloque les IP malveillantes après plusieurs échecs,  
- `unattended-upgrades` → applique automatiquement les patchs de sécurité,  
- `auditd` → surveille les fichiers et commandes critiques,  
- Bannières légales (`/etc/issue`, `/etc/motd`),  
- `sysctl` → durcissement du noyau et des paramètres réseau,  
- Script de vérification rapide type CIS.

---

## 🚀 Installation rapide

Clonez la branche améliorée :

```bash
git clone -b feat/hardening-advanced https://github.com/<ton_username>/linux-secure-vm-setup.git
cd linux-secure-vm-setup

chmod +x setup.sh hardening/cis-check.sh
````

Lancez le tout :

```bash
sudo ./setup.sh all
```

Ou uniquement la sécurité avancée :

```bash
sudo ./setup.sh 4
```

---

## 🔍 Étape 4 — Détail des améliorations

### 1️⃣ `fail2ban`

* Installe et active `fail2ban`.
* Surveille les logs SSH.
* Banni une IP après **3 échecs en 10 minutes** (bannissement d’1 heure).
  
📌 **Pourquoi ?** → éviter les attaques par force brute sur SSH.

👉 Fichier de config : `hardening/fail2ban/jail.local`

---

### 2️⃣ `unattended-upgrades`

* Active les mises à jour automatiques de sécurité.
* Supprime les vieux kernels inutiles.
* Redémarre automatiquement à **03:30** si besoin.

📌 **Pourquoi ?** → s’assurer que la machine reste patchée sans intervention manuelle.

👉 Fichiers :

* `hardening/unattended/50unattended-upgrades`
* `hardening/unattended/20auto-upgrades`

---

### 3️⃣ `auditd`

* Ajoute des règles pour surveiller les fichiers critiques :

  * `/etc/passwd`, `/etc/shadow`, `/etc/sudoers`,
  * `/var/log/`,
  * exécution des commandes (`execve`).

📌 **Pourquoi ?** → savoir si quelqu’un modifie des fichiers sensibles.

👉 Fichier : `hardening/auditd/audit.rules`

Logs visibles avec :

```bash
sudo ausearch -k identity
sudo aureport -a
```

---

### 4️⃣ Bannières légales

* Ajoute une bannière sur l’écran de login (`/etc/issue`) et après connexion (`/etc/motd`).

📌 **Pourquoi ?** → avertir que l’accès est réservé, et que l’activité peut être surveillée.

👉 Fichiers :

* `hardening/banners/issue`
* `hardening/banners/motd`

---

### 5️⃣ `sysctl` (durcissement noyau & réseau)

* Désactive IP forwarding.
* Bloque les redirections ICMP non désirées.
* Active l’ASLR (randomisation de la mémoire).
* Restreint l’accès au kernel logs (`dmesg`).

📌 **Pourquoi ?** → réduire la surface d’attaque au niveau noyau/réseau.

👉 Fichier : `hardening/sysctl/99-hardening.conf`

Vérifier l’application :

```bash
sudo sysctl -a | grep -E "redirect|forward|rp_filter"
```

---

### 6️⃣ Vérifications rapides (CIS-like check)

Un petit script est fourni pour vérifier l’état de sécurité :

```bash
sudo ./hardening/cis-check.sh
```

Exemple de sortie :

```
== Quick CIS-like checks ==
- PasswordAuthentication: no
- PermitRootLogin: no
- UFW status: active
- Unattended-upgrades: enabled
- Fail2ban: active
- Auditd: active
```

👉 Fichier : `hardening/cis-check.sh`

---

## 📂 Organisation spécifique aux améliorations

```
hardening/
├── auditd/
│   └── audit.rules          # Règles auditd
├── banners/
│   ├── issue                # Bannière avant login
│   └── motd                 # Message après login
├── fail2ban/
│   └── jail.local           # Config fail2ban
├── sysctl/
│   └── 99-hardening.conf    # Paramètres noyau & réseau
├── unattended/
│   ├── 20auto-upgrades      # Active la MAJ auto
│   └── 50unattended-upgrades# Politique de MAJ
└── cis-check.sh             # Vérifications rapides
```

---

## ✅ Vérifications après installation

* Fail2ban :

  ```bash
  sudo fail2ban-client status sshd
  ```
* Unattended-upgrades :

  ```bash
  systemctl status unattended-upgrades
  ```
* Auditd :

  ```bash
  sudo ausearch -k exec
  ```
* Bannières : déconnectez/reconnectez → message visible.
* Sysctl :

  ```bash
  sudo sysctl -a | grep randomize_va_space
  ```

---

## 🛠️ Améliorations futures possibles

* `logwatch` → recevoir des rapports quotidiens par mail.
* `rkhunter` ou `chkrootkit` → détection de rootkits.
* Tests automatisés de conformité (ex. Lynis, OpenSCAP).
* Intégration CI/CD avec Molecule (test de rôles Ansible).

---

## 👤 Auteur

Projet maintenu par **Théo FRANÇOIS** – Administrateur Systèmes & Réseaux (Linux & Sécurité).
👉 Cette branche montre le passage du **setup rapide** (README) à une configuration **durcie** et plus proche des bonnes pratiques en production.
