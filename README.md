# 🚀 Linux Secure VM Setup (AIS)

Ce dépôt vous permet de transformer une VM **vierge** (Debian/Ubuntu)  
en une machine **opérationnelle** et **sécurisée**, prête pour apprendre ou travailler comme **Administrateur Infrastructures Sécurisées**.

🎯 Objectif : en **une seule commande**, vous installez :  
- Mises à jour + outils de base,  
- Création d’un utilisateur non-root avec sudo,  
- Durcissement SSH (root interdit, clé SSH recommandée),  
- Pare-feu UFW actif,  
- Monitoring de base avec Prometheus Node Exporter.  

Ce projet est pensé pour :  
1. **Un usage perso** → déployer rapidement une VM propre.  
2. **Les débutants** → comprendre pas-à-pas pourquoi on fait ces choix.

---

## ⚙️ 1. Pré-requis

- Une VM Debian/Ubuntu **fraîchement installée** (ex. VirtualBox, Proxmox, VMware).  
- Un accès **root** (par mot de passe ou via `sudo`).  
- Git installé (sinon : `sudo apt install -y git`).  
- (optionnel mais recommandé) Une clé SSH déjà générée sur votre machine d’admin.

---

## 📥 2. Installation

Clonez le dépôt et rendez les scripts exécutables :

```bash
git clone https://github.com/<ton_username>/linux-secure-vm-setup.git
cd linux-secure-vm-setup

chmod +x setup.sh hardening/ufw_rules.sh monitoring/install_node_exporter.sh
```

---

## 🚀 3. Lancer le script

### Tout en une fois

```bash
sudo ./setup.sh
```

Par défaut :

* Utilisateur créé → **aisadmin**
* Port SSH → **22**
* Fuseau horaire → **Europe/Paris**

Vous pouvez personnaliser :

```bash
sudo NEW_USER=theo SSH_PORT=2222 TIMEZONE=UTC ./setup.sh all
# 🔒 Linux Secure VM Setup — Améliorations avancées

---

## 🔍 4. Détail des étapes

### Étape 1 — Base système

* Met à jour la VM (`apt update && apt upgrade`).
* Installe des outils utiles : `curl`, `git`, `vim`, `htop`, `tmux`, `net-tools`…
* Configure le fuseau horaire et NTP.
  📌 **Pourquoi ?** → avoir un système à jour et les outils essentiels dès le départ.

---

### Étape 2 — Utilisateur + SSH

* Crée l’utilisateur `${NEW_USER}` (par défaut `aisadmin`) avec droits `sudo`.
* Prépare son dossier `~/.ssh/authorized_keys`.
* Copie les clés root si elles existent (utile sur une VM de test).
* Applique une configuration SSH sécurisée :

  * `PermitRootLogin no` → interdit root en SSH.
  * `PasswordAuthentication no` si une clé est détectée.
    📌 **Pourquoi ?** → on évite de travailler en root directement et on sécurise SSH.

⚠️ **Attention** : si vous n’avez pas encore copié de clé publique dans la VM,
le script laisse `PasswordAuthentication yes` pour éviter de vous bloquer.
Ensuite, ajoutez une clé avec :

```bash
ssh-copy-id ${NEW_USER}@<IP_VM> -p <SSH_PORT>
```

Puis désactivez le mot de passe dans `/etc/ssh/sshd_config`.

---

### Étape 3 — UFW (firewall)

* Active UFW (Uncomplicated Firewall).
* Bloque tout en entrée sauf le port SSH.
* Autorise tout en sortie.
  📌 **Pourquoi ?** → limiter les attaques réseau, ne garder ouvert que ce dont on a besoin.

---

### Étape 5 — Monitoring (Node Exporter)

* Installe **Prometheus Node Exporter**.
* Lance un service systemd (actif au boot).
* Expose les métriques sur `http://<IP_VM>:9100/metrics`.
  📌 **Pourquoi ?** → utile si vous voulez surveiller votre VM (Prometheus/Grafana).
  Pour débuter, ouvrez juste l’URL dans un navigateur.

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

## 📝 Vérification post-installation (avancé)

Utilisez la **checklist interactive** sur GitHub pour valider la configuration durcie :

➡️ [Vérification post-install (avancé)](../../issues/new?template=post-install-checklist-advanced.md)

Cette checklist couvre :
- Base (SSH, UFW, Node Exporter),
- Sécurité avancée (fail2ban, unattended-upgrades, auditd, bannières, sysctl).

---

## 📂 5. Organisation du dépôt

```
linux-secure-vm-setup/
├── README.md                     # Documentation (ce fichier)
├── setup.sh                      # Script principal (orchestrateur)
├── hardening/
│   ├── ssh_config                # Configuration SSH sécurisée
│   └── ufw_rules.sh              # Script UFW (firewall)
└── monitoring/
    └── install_node_exporter.sh  # Script monitoring Prometheus
```

* `setup.sh` → script principal (enchaîne tout).
* `hardening/ssh_config` → fichier modèle appliqué sur `/etc/ssh/sshd_config`.
* `hardening/ufw_rules.sh` → définit les règles du firewall.
* `monitoring/install_node_exporter.sh` → installe le monitoring basique.

---

## ✅ 6. Vérifications après installation

* Connexion SSH :

  ```bash
  ssh aisadmin@<IP_VM> -p 22
  ```
* Firewall :

  ```bash
  sudo ufw status verbose
  ```
* Services actifs :

  ```bash
  systemctl status ssh ufw node_exporter
  ```
* Monitoring : ouvrez [http://\<IP\_VM>:9100/metrics](http://<IP_VM>:9100/metrics).

---

## 🛠️ 7. Améliorations futures

* `fail2ban` → bloque les IP après tentatives ratées.
* `unattended-upgrades` → mises à jour de sécurité automatiques.
* `auditd` → journalisation avancée.
* Bannières légales (`/etc/issue`, `/etc/motd`).
* `sysctl` → durcissement réseau & kernel.

👉 Ces éléments sont disponibles dans la branche **feat/hardening-advanced**.

---

## 🎓 8. Pour les débutants

Ce projet est aussi un **guide d’apprentissage** :

* Chaque étape du script correspond à une **bonne pratique en sécurité Linux**.
* Vous pouvez lire les fichiers (`setup.sh`, `ssh_config`, etc.) pour comprendre ce qui se passe.
* Essayez de lancer les étapes une par une :

  ```bash
  sudo ./setup.sh 1   # uniquement la base
  sudo ./setup.sh 2   # ajout utilisateur + SSH
  ```
* Puis regardez les différences (`ufw status`, `sshd -T`, etc.).

---

## 📝 Vérification post-installation

Pour vous aider à vérifier que tout est bien installé et configuré,  
vous pouvez utiliser la **checklist interactive** directement sur GitHub :

➡️ [Vérification post-install (base)](../../issues/new?template=post-install-checklist.md)

Cette checklist vous guidera étape par étape pour valider :
- Connexion SSH avec le nouvel utilisateur,
- Firewall UFW actif,
- Durcissement SSH,
- Node Exporter en service.


## 👤 Auteur

Projet créé par **Théo FRANÇOIS** – Administrateur Systèmes & Réseaux (Linux & Sécurité).
👉 Objectif : un dépôt **utile aux débutants** et **valeur ajoutée sur GitHub** pour un futur poste en **Administrateur Infrastructures Sécurisées**.


---

## 🛠️ Améliorations futures possibles

* `logwatch` → recevoir des rapports quotidiens par mail.
* `rkhunter` ou `chkrootkit` → détection de rootkits.
* Tests automatisés de conformité (ex. Lynis, OpenSCAP).
* Intégration CI/CD avec Molecule (test de rôles Ansible).

