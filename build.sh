#!/bin/bash

REMOVE_VOLUMES=false

# Parse options
while getopts "r" opt; do
	case $opt in
		r)
			REMOVE_VOLUMES=true
			;;
		*)
			echo "Usage: $0 [-r]"
			exit 1
			;;
	esac
done

# Check if Docker service is running
if ! systemctl is-active --quiet docker; then
	echo "Docker is not running. Starting Docker..."
	sudo systemctl start docker
	# Optional: Wait a few seconds for Docker to start
	sleep 5
fi

# Remove containers and optionally volumes
if [ "$REMOVE_VOLUMES" = true ]; then
	echo "⚠️ Stopping and removing containers and volumes !!!"
	docker compose down -v
else
	echo "Stopping and removing containers..."
	docker compose down
fi

# Build and start containers
docker compose up --build
