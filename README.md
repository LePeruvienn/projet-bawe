# FEUR — Mini réseau social

Projet réalisé dans le cadre du module *Bases du Web (BAWE)*.

FEUR est un petit réseau social permettant de créer un compte, publier des messages, liker des posts, changer la langue (FR/EN) et basculer entre un thème clair/sombre.
Le projet se compose de :

* un **backend en Rust (Axum)**
* un **frontend en Flutter Web**
* une **base PostgreSQL**

---

# 📦 **Structure du projet**

```
/
├── backend/        (Serveur Rust + Axum)
├── frontend/       (Flutter Web)
├── database/       (Création et insertion des tables)
└── README.md
```

---

# 🚀 Guide d'Installation et de Lancement

Ce projet full-stack est composé d'un **backend** développé en **Rust** et d'un **frontend** développé en **Flutter** (pour le Web).

## 📋 Prérequis

Assurez-vous que les outils et services suivants sont installés sur votre système :

  * **Rust et Cargo**
  * **Flutter SDK** (configuré pour le développement Web, ex: `flutter doctor -v` doit être propre)
  * **PostgreSQL Server** (version 10 ou supérieure recommandée)
  * **Client PostgreSQL** (`psql`)

## 1\. 🐘 Configuration de la Base de Données PostgreSQL

Le backend nécessite une instance PostgreSQL démarrée et configurée.

### A. Démarrage du Service

Assurez-vous que le service PostgreSQL est lancé. Sur la plupart des distributions Linux utilisant Systemd :

```bash
sudo systemctl start postgresql
sudo systemctl enable postgresql # Pour un démarrage automatique
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

Importez le schéma de la base de données à partir des fichiers SQL.

```bash
cd database/
for sqlfile in *.sql; do
    echo "➡️ Import de $sqlfile ..."
    # Le mot de passe sera demandé ou doit être configuré via la variable PGPASSWORD
    psql -U appdb -d appdb -h localhost -f "$sqlfile"
done
cd ..
```

-----

## 2\. ⚙️ Lancement du Backend (Rust)

Le backend écoute sur `localhost` et se connecte à la base de données `appdb`.

1.  **Naviguez vers le répertoire du backend :**
    ```bash
    cd backend
    ```
2.  **Lancez l'application en mode release** (pour de meilleures performances) :
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
    flutter run -d chrome --release
    ```
    Flutter lancera un navigateur Chrome pointant vers l'application Web. Le frontend interagit avec le backend Rust.

-----

## 🛑 Arrêt du Projet

Pour arrêter l'application, vous devez arrêter les deux processus manuellement :

1.  **Backend Rust :** Revenez au terminal où `cargo run` est actif et appuyez sur **`Ctrl+C`**.
2.  **Frontend Flutter :** Revenez au terminal où `flutter run` est actif et appuyez sur **`q`** ou **`Ctrl+C`**.

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
