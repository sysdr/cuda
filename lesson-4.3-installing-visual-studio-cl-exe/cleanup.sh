#!/usr/bin/env bash
# Stop running containers and prune unused Docker resources.
set -uo pipefail

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed or not on PATH. Skipping container cleanup."
  exit 0
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker daemon is not reachable. Skipping container cleanup."
  exit 0
fi

echo "=== Stopping running containers ==="
running="$(docker ps -q 2>/dev/null || true)"
if [ -n "$running" ]; then
  docker stop $running
else
  echo "  No running containers."
fi

echo "=== Removing all containers ==="
all_containers="$(docker ps -aq 2>/dev/null || true)"
if [ -n "$all_containers" ]; then
  docker rm -f $all_containers
else
  echo "  No containers to remove."
fi

echo "=== Removing unused images ==="
docker image prune -af

echo "=== Removing unused volumes, networks, and build cache ==="
docker system prune -af --volumes

echo "=== Docker cleanup complete ==="
docker system df
