#!/bin/bash

# ⚠️ THIS DELETE ALL VOLUMS PLEASE BE CAREFUL !
# Remove existing volumes and containers
docker compose down -v

# Build and start your containers
docker compose up --build
