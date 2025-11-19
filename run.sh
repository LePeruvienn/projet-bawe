#!/bin/bash

set -euo pipefail

# ----------------------------
# Configuration
# ----------------------------
DB_USER="appdb"
DB_PASSWORD="appdb"
DB_NAME="appdb"
DB_HOST="localhost"
PG_DATA_DIR="/var/lib/postgres/data"

DB_PORT="5432"
BACKEND_PORT="8080"
FRONTEND_PORT="8000"

EXIT_CODE=0

# ----------------------------
# Vérification des commandes
# ----------------------------
for cmd in cargo flutter psql systemctl initdb curl; do
	command -v $cmd >/dev/null 2>&1 || { echo "❌ $cmd n'est pas installé"; exit 1; }
done

# ----------------------------
# Vérification des ports
# ----------------------------

if ss -tuln | grep -E ":($BACKEND_PORT|$FRONTEND_PORT) " > /dev/null; then
	echo "❌ Some ports are already in use : $BACKEND_PORT, $FRONTEND_PORT"
	echo "   Please set these port free before running the script."
	echo "   -> cant run project exiting ..."
	EXIT_CODE=1
	exit $EXIT_CODE
else
	echo "✅ All ports are free"
fi


echo "---------------------------------------------"
echo "🔄 Vérification du service PostgreSQL..."
echo "---------------------------------------------"

# ----------------------------
# Initialisation PostgreSQL si nécessaire
# ----------------------------

if ! sudo test -d "$PG_DATA_DIR"; then
	echo "📂 Initialisation de PostgreSQL..."
	sudo -iu postgres initdb --locale=C.UTF-8 --encoding=UTF8 -D "$PG_DATA_DIR"
else
	echo "✅ PostgreSQL déjà initialisé."
fi

# ----------------------------
# Démarrage du service PostgreSQL
# ----------------------------
if ! systemctl is-active --quiet postgresql; then
	echo "🐘 Démarrage du service PostgreSQL..."
	sudo systemctl start postgresql
	sleep 3
fi

# ----------------------------
# Création de l'utilisateur PostgreSQL si nécessaire
# ----------------------------
USER_EXISTS=$(sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER'")
if [ "$USER_EXISTS" != "1" ]; then
	echo "➕ Création de l'utilisateur PostgreSQL '$DB_USER'..."
	sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';"
else
	echo "✅ Utilisateur '$DB_USER' existe déjà."
fi

# ----------------------------
# Création de la base si nécessaire
# ----------------------------
DB_EXISTS=$(sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'")
if [ "$DB_EXISTS" != "1" ]; then
	echo "➕ Création de la base de données '$DB_NAME'..."
	sudo -u postgres psql -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;"
else
	echo "✅ Base '$DB_NAME' existe déjà."
fi

# Donner tous les droits à appdb sur le schéma public
sudo -u postgres psql -d $DB_NAME -c "ALTER SCHEMA public OWNER TO $DB_USER;"
sudo -u postgres psql -d $DB_NAME -c "GRANT ALL PRIVILEGES ON SCHEMA public TO $DB_USER;"
sudo -u postgres psql -d $DB_NAME -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $DB_USER;"
sudo -u postgres psql -d $DB_NAME -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $DB_USER;"
sudo -u postgres psql -d $DB_NAME -c "GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO $DB_USER;"

# ----------------------------
# Import de la structure
# ----------------------------
echo "📂 Import de la structure de la base..."
for sqlfile in database/*.sql ; do
	echo "➡️ Import de $sqlfile ..."
	psql -U $DB_USER -d $DB_NAME -h $DB_HOST -p $DB_PORT -f "$sqlfile"
done

# ----------------------------
# Lancement backend Rust
# ----------------------------

# Build backend
echo "🔧 Building backend Rust..."
cd backend
cargo build --release

# Run API
echo "🚀 Lancement du backend Rust..."
cargo run --release &
BACKEND_PID=$!
cd ..

# Verify that backend is running 
wait_time=3
max_retries=10
retry=0
echo "⏳ Waiting for backend on port $BACKEND_PORT..."
until curl -sf "http://localhost:$BACKEND_PORT/" > /dev/null; do
	retry=$((retry + 1))

	if [ "$retry" -ge "$max_retries" ]; then
		echo "❌ Backend did not respond after $max_retries attempts."
		EXIT_CODE=1
		exit $EXIT_CODE
	fi

	echo "   Still waiting... ($retry/$max_retries)"
	sleep $wait_time
done
echo "✅ Backend is ready!"


# ----------------------------
# Lancement frontend Flutter Web
# ----------------------------

echo "🌐 Lancement du frontend Flutter Web..."
cd frontend
flutter clean
flutter run -d chrome --release --web-port 8000 --web-hostname 0.0.0.0 &
FRONTEND_PID=$!
cd ..

# ----------------------------
# Gestion Ctrl+C pour arrêter proprement
# ----------------------------
function cleanup {
	echo "🛑 Arrêt des serveurs..."
	kill $BACKEND_PID $FRONTEND_PID || true
	exit $EXIT_CODE
}

# Added trop be sure to kill process when exiting or Ctr+C
trap cleanup SIGINT
trap cleanup EXIT

wait
