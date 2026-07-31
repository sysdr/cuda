#!/usr/bin/env bash
# Stop containers and remove unused Docker resources (containers, images, networks, volumes).
set -euo pipefail

echo "==> Docker cleanup starting"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker CLI not found; nothing to clean."
  exit 0
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker daemon is not reachable. Trying to start it briefly is skipped;"
  echo "attempting cleanup commands anyway where possible."
fi

echo "==> Stopping all running containers"
if docker ps -q 2>/dev/null | grep -q .; then
  docker stop $(docker ps -q) || true
else
  echo "No running containers."
fi

echo "==> Removing all stopped containers"
docker container prune -f || true

echo "==> Removing unused images"
docker image prune -a -f || true

echo "==> Removing unused networks"
docker network prune -f || true

echo "==> Removing unused volumes"
docker volume prune -f || true

echo "==> Removing build cache"
docker builder prune -a -f || true

echo "==> Final docker system prune"
docker system prune -a -f --volumes || true

echo "==> Docker cleanup finished"
docker system df 2>/dev/null || true
