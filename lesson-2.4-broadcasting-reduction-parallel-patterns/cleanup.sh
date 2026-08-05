#!/usr/bin/env bash
# Stop containers and prune unused Docker resources (containers, images, networks, volumes).
set -euo pipefail

echo "==> Docker cleanup starting"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed; nothing to clean."
  exit 0
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker daemon is not running; attempting to start..."
  if command -v systemctl >/dev/null 2>&1; then
    sudo systemctl start docker 2>/dev/null || systemctl start docker 2>/dev/null || true
  elif command -v service >/dev/null 2>&1; then
    sudo service docker start 2>/dev/null || service docker start 2>/dev/null || true
  fi
  sleep 2
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker daemon is still unavailable; skipping container/image cleanup."
  exit 0
fi

echo "==> Stopping all running containers"
running="$(docker ps -q 2>/dev/null || true)"
if [[ -n "${running}" ]]; then
  docker stop ${running}
else
  echo "No running containers."
fi

echo "==> Removing all containers"
all_containers="$(docker ps -aq 2>/dev/null || true)"
if [[ -n "${all_containers}" ]]; then
  docker rm -f ${all_containers}
else
  echo "No containers to remove."
fi

echo "==> Removing unused images, networks, and build cache"
docker system prune -af

echo "==> Removing unused volumes"
docker volume prune -f

echo "==> Remaining Docker resources"
docker ps -a || true
docker images || true

echo "==> Docker cleanup finished"
