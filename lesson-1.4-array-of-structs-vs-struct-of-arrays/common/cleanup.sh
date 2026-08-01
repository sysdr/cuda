#!/usr/bin/env bash
# Stop all Docker containers and remove unused Docker resources.
set -euo pipefail

echo "=== Docker cleanup ==="

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed or not in PATH. Nothing to clean."
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

echo "Removing all containers..."
all_containers="$(docker ps -aq 2>/dev/null || true)"
if [[ -n "${all_containers}" ]]; then
  docker rm -f ${all_containers}
else
  echo "No containers to remove."
fi

echo "Removing unused images..."
docker image prune -af

echo "Removing unused volumes..."
docker volume prune -f

echo "Removing unused networks..."
docker network prune -f

echo "Removing build cache and other unused resources..."
docker system prune -af --volumes

echo "=== Docker cleanup complete ==="
docker system df || true
