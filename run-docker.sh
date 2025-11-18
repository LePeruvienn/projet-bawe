#!/bin/bash

REMOVE_VOLUMES=false


# Check all arguments options
while [[ $# -gt 0 ]]; do
	case "$1" in
		--remove-volumes | -rv)
			REMOVE_VOLUMES=true
		;;
		--help | -h)
			echo "Displaying help..."
		;;
		*)
			echo "Unknown option: $1"
		;;
	esac

	shift 1
done


printf "\n"
echo "---------------------------------------------"
echo "🔨 Running build for : Projet BAWE S1 ..."
echo "---------------------------------------------"
printf "\n"

# Check if Docker service is running
if ! systemctl is-active --quiet docker; then
	printf "\n"
	echo "🐳 Docker is not running. Starting Docker.."
	printf "\n"
	sudo systemctl start docker
	# Optional: Wait a few seconds for Docker to start
	sleep 5
fi

# Remove containers and optionally volumes
if [ "$REMOVE_VOLUMES" = true ]; then
	echo "⚠️ Stopping and removing containers and volumes !!!"
	printf "\n"
	docker compose down -v
else
	echo "⭕ Stopping and removing containers..."
	printf "\n"
	docker compose down
fi

echo "🏁 Ready : starting containers !"
printf "\n"

echo "--------------------------------"

# Build and start containers
docker compose up --build
