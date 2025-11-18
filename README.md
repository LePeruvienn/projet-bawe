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

# 🚀 **Lancer le projet**

## 1. Prérequis

Assurez-vous d’avoir installé :

### 🦀 Rust

```
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### 🐘 PostgreSQL

```
sudo pacman -S postgresql
```

### 🎨 Flutter Web

```
sudo pacman -S flutter
flutter config --enable-web
```

---

## 2. Création de la base de données

Démarrer PostgreSQL :

```
sudo systemctl start postgresql
```

Initialiser la base (si première installation) :

```
sudo -iu postgres initdb -D /var/lib/postgres/data
sudo systemctl restart postgresql
```

Créer l’utilisateur et la base :

```
sudo -iu postgres psql
CREATE USER feur WITH PASSWORD 'feur';
CREATE DATABASE feur OWNER feur;
\q
```

Importer la structure :

```
TODO: CHANGE
psql -U feur -d feur -f database.sql
```

---

## 3. Lancer le backend (Rust)

```
cd backend/
cargo run
```

Le serveur démarre sur :
➡️ [http://localhost:3000](http://localhost:3000)

---

## 4. Lancer le frontend (Flutter Web)

```
cd frontend/
flutter pub get
flutter run -d chrome
```

Le site s’ouvre automatiquement dans votre navigateur.

---

# 📘 **Résumé rapide**

| Composant            | Commande (sans Docker)  | Port           |
| -------------------- | ----------------------- | -------------- |
| Backend Rust         | `cargo run`             | 3000           |
| Frontend Flutter Web | `flutter run -d chrome` | 8080 (ou auto) |
| PostgreSQL           | `psql -U feur -d feur`  | 5432           |

---

# 🧪 **Tests rapides**

* Liker un post
* Changer de langue
* Changer le thème
* Créer et supprimer un compte
* Vérifier la persistance des données dans PostgreSQL

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
