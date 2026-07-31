#!/usr/bin/env bash
# Stop running containers and prune unused Docker resources.
set -euo pipefail

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker CLI not found; nothing to clean."
  exit 0
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker daemon is not reachable; skipping container/image cleanup."
  exit 0
fi

echo "Stopping all running containers..."
running="$(docker ps -q)"
if [[ -n "${running}" ]]; then
  docker stop ${running}
else
  echo "  (none running)"
fi

echo "Removing all containers..."
all="$(docker ps -aq)"
if [[ -n "${all}" ]]; then
  docker rm -f ${all}
else
  echo "  (none present)"
fi

echo "Pruning unused Docker resources (containers, networks, images, build cache)..."
docker system prune -af --volumes

echo "Docker cleanup complete."
docker system df || true
