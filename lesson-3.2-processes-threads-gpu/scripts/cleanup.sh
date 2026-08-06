#!/usr/bin/env bash
# Stop running containers and prune unused Docker resources.
set -euo pipefail

echo "==> Docker cleanup"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed or not on PATH. Nothing to clean."
  exit 0
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker daemon is not reachable. Skipping container/image cleanup."
  exit 0
fi

echo "Stopping all running containers..."
running="$(docker ps -q 2>/dev/null || true)"
if [[ -n "${running}" ]]; then
  docker stop ${running}
else
  echo "No running containers."
fi

echo "Removing all stopped containers..."
docker container prune -f

echo "Removing unused images..."
docker image prune -a -f

echo "Removing unused volumes..."
docker volume prune -f

echo "Removing unused networks..."
docker network prune -f

echo "Removing build cache..."
docker builder prune -af 2>/dev/null || true

echo "Docker cleanup complete."
docker system df 2>/dev/null || true
