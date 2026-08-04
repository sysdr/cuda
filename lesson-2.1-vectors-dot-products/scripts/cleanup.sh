#!/usr/bin/env bash
# Stop all Docker containers and prune unused Docker resources.
set -euo pipefail

echo "==> Docker cleanup starting..."

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed or not on PATH. Nothing to clean."
  exit 0
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker daemon is not reachable. Nothing to clean."
  exit 0
fi

echo "==> Stopping running containers..."
running="$(docker ps -q 2>/dev/null || true)"
if [[ -n "${running}" ]]; then
  docker stop ${running}
else
  echo "No running containers."
fi

echo "==> Removing all containers..."
all_containers="$(docker ps -aq 2>/dev/null || true)"
if [[ -n "${all_containers}" ]]; then
  docker rm -f ${all_containers}
else
  echo "No containers to remove."
fi

echo "==> Removing unused images, networks, volumes, and build cache..."
docker system prune -af --volumes

echo "==> Removing dangling / unused images (explicit)..."
docker image prune -af

echo "==> Docker cleanup complete."
docker system df || true
