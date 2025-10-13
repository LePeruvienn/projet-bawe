# 🦀 Projet BAWE - Arthur

Petit projet développé en *Rust* (Axum + SQLx), *PostgreSQL* & *Flutter* !

## Prérequis

Installer Docker :

- Installer docker puis lancer docker

```bash
sudo pacman -S docker
sudo systemctl start docker
```

## Prérequis

Lancer le projet :

- Avec le script `build.sh`


⚠️ Attention le script `build.sh` supprimer tout vos volume docker. Pensez à bien sauvegarder vos autres volumes ou utilisé la méthode si dessous.

```bash
# Ajouter la permission si ce n'est pas déjà fait
chmod +x build.sh

# Lancer le script
./build.sh
```


- Avec la commande docker

```bash
docker compose up --build
```
