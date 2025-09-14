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
````

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
```

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

## 👤 Auteur

Projet créé par **Théo FRANÇOIS** – Administrateur Systèmes & Réseaux (Linux & Sécurité).
👉 Objectif : un dépôt **utile aux débutants** et **valeur ajoutée sur GitHub** pour un futur poste en **Administrateur Infrastructures Sécurisées**.

