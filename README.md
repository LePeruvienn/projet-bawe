# FEUR - Mini réseau social

Projet réalisé dans le cadre du module *Bases du Web (BAWE)*.

FEUR est un petit réseau social permettant de créer un compte, publier des messages, liker des posts, changer la langue (FR/EN) et basculer entre un thème clair/sombre.
Le projet se compose de :

* un **backend en Rust (Axum)**
* un **frontend en Flutter Web**
* une **base PostgreSQL**

---

# 📘 Le rapport : `rapport/rapport.pdf`.

Le rapport se trouve dans Le rapport se trouve à cette endroit

---

# 📦 **Structure du projet**

```
/
├── backend/        (Serveur Rust + Axum)
├── frontend/       (Flutter Web)
├── database/       (Création et insertion des tables)
├── rapport/        (La ou se trouve le rapport.pdf)
└── README.md
```

**Ports des différents services** :

- `5432` : Base de données (PostgreSQL)
- `8080` : API Web (Rust)
- `8000` : Client Web (Flutter)

Pour acceder au site internet : [](http://0.0.0.0:8000/)

---

# 🚀 Guide d'Installation et de Lancement

Ce projet full-stack est composé d'un **backend** développé en **Rust** et d'un **frontend** développé en **Flutter** (pour le Web).

## 📋 Prérequis

Assurez-vous que les outils et services suivants sont installés sur votre système :

  * **Rust et Cargo**
  * **Flutter SDK** (configuré pour le développement Web, ex: `flutter doctor -v` doit être propre)
  * **PostgreSQL** (et `psql`)

Je vous explique si dessous comment mettre en place ces dépendances.


1. **Installation de `cargo` et `postgresql`** (ici avec Archlinux) :

```bash
sudo pacman -S postgresql
sudo pacman -S cargo
```

2. **Installation de `flutter`**, peut être un peu plus compliquer :

```bash
# Sous Archlinux avec un AUR helper tel que `yay` 
yay -S flutter ou flutter-bin

# Ou tu peut le compiler toi meme en clonant le repo git
git clone https://github.com/flutter/flutter.git -b stable
```

3. **Configuration de `flutter` en mode web** :

Tout d'abord on active le mode web sur `flutter`

```bash
flutter config --enable-web
```

Ensuite meme si le site doit être fonctionnel sous firefox, il nous faut chrome pour lancer le server web.

```bash
flutter doctor
```

Si on voit la ligne `[✓] Chrome - develop for the web` alors c'est bon !

Sinon il faut :
- Installer `chromium` ou `chrome` (pas besoin si vous avez déjà un des deux)
- Mettre la variable d'environnement `CHROME_EXECUTABLE`

```bash
# Installer chromium
sudo pacman -S chromium

# Mettre le chemin de l'executable (peut varier)
export CHROME_EXECUTABLE=/usr/bin/chromium
```

On peut re vérifier que tout est bon :

```bash
flutter doctor
```

## 💻 Script de lancement

Vous pouvez lancer le projet à l'aide du script `run.sh` ou `run-docker.sh` (mais necessites les dépendances de docker).

```bash
./run.sh # Pour un lancement SANS docker
./run-docker.sh # Pour un lancement AVEC docker
```

Si vous ne préferez pas je vous laisse suivre les instruction ci dessous.

## 1\. 🐘 Configuration de la Base de Données PostgreSQL

Le backend nécessite une instance PostgreSQL démarrée et configurée.

### A. Démarrage du Service

Assurez-vous que le service PostgreSQL est lancé. Sur la plupart des distributions Linux utilisant Systemd :

```bash
sudo systemctl start postgresql
```

Si vous avez une erreur et que vous êtes sous archlinux, il faut parfois initialiser postgresql avant de le lancer :

```bash
sudo -iu postgres initdb --locale=C.UTF-8 --encoding=UTF8 -D "$PG_DATA_DIR"
```

### B. Création de l'Utilisateur et de la Base de Données

Les configurations par défaut sont :

  * **Utilisateur:** `appdb`
  * **Mot de passe:** `appdb`
  * **Base de Données:** `appdb`

Exécutez les commandes suivantes en tant qu'utilisateur `postgres` (généralement via `sudo`) pour créer les ressources nécessaires :

1.  **Créer l'utilisateur:**
    ```bash
    sudo -u postgres psql -c "CREATE USER appdb WITH PASSWORD 'appdb';"
    ```
2.  **Créer la base de données et l'attribuer à l'utilisateur:**
    ```bash
    sudo -u postgres psql -c "CREATE DATABASE appdb OWNER appdb;"
    ```
3.  **Attribuer les droits nécessaires** (pour s'assurer que l'utilisateur `appdb` peut gérer le schéma `public`) :
    ```bash
    sudo -u postgres psql -d appdb -c "GRANT ALL PRIVILEGES ON SCHEMA public TO appdb;"
    ```

### C. Importation de la Structure

Importez le schéma de la base de données à partir des fichiers SQL qui se trouve dans `/database` :

```bash
# Le mot de passe sera demandé ou doit être configuré via la variable PGPASSWORD
psql -U appdb -d appdb -h localhost -f database/1_reset.sql
psql -U appdb -d appdb -h localhost -f database/2_tables.sql
psql -U appdb -d appdb -h localhost -f database/3_inserts.sql
```

-----

## 2\. ⚙️ Lancement du Backend (Rust)

Le backend écoute sur `localhost` et se connecte à la base de données `appdb`.

1. **Naviguez vers le répertoire du backend :**

```bash
cd backend
```

2. **Lancez l'application en mode release** (pour de meilleures performances) :

```bash
cargo run --release
```

Le serveur devrait démarrer et afficher l'adresse où il écoute (ex: `http://127.0.0.1:8080`).

-----

## 3\. 🌐 Lancement du Frontend (Flutter Web)

Le frontend se connecte au backend pour afficher l'interface utilisateur.

1.  **Naviguez vers le répertoire du frontend :**

```bash
cd frontend
```

2.  **Nettoyez et lancez le projet en mode release sur Chrome :**

```bash
flutter clean
flutter run -d chrome --release --web-port 8000 --web-hostname 0.0.0.0
```

Flutter lancera un navigateur Chrome pointant vers l'application Web. Le frontend interagit avec le backend Rust.

-----

## 🛑 Arrêt du Projet

Pour arrêter l'application, vous devez arrêter les deux processus manuellement :

1. **Backend Rust :** Revenez au terminal où `cargo run` est actif et appuyez sur **`Ctrl+C`**.
2. **Frontend Flutter :** Revenez au terminal où `flutter run` est actif et appuyez sur **`q`** ou **`Ctrl+C`**.

---

# 🐞 **Bugs connus**

* Le like peut disparaître après un changement de résolution.
* Le thème peut parfois ne pas s’appliquer immédiatement.
* Il est possible de supprimer son propre compte.

---

# ✔️ **Projet conforme**

TODO: 
Ce projet respecte l’intégralité des consignes du sujet BAWE.

---

*Arthur PINEL - ENSIIE FISA 2025*
