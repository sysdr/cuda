#!/usr/bin/env bash
# Stop containers and remove unused Docker resources for this workspace.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

echo "==> Project artifact cleanup in ${ROOT_DIR}"
find . -type d \( -name node_modules -o -name venv -o -name .venv -o -name .pytest_cache -o -name __pycache__ \) -prune -exec rm -rf {} + 2>/dev/null || true
find . -type f \( -name '*.pyc' -o -name '*.pyo' \) -delete 2>/dev/null || true
find . \( -iname '*istio*' -o -name 'istioctl' \) ! -path './.git/*' -print -exec rm -rf {} + 2>/dev/null || true
echo "    Artifact sweep complete."

if ! command -v docker >/dev/null 2>&1; then
  echo "==> Docker not installed or not on PATH; skipping container/image cleanup."
  exit 0
fi

if [[ -f docker-compose.yml || -f docker-compose.yaml || -f compose.yml || -f compose.yaml ]]; then
  echo "==> Stopping project Compose services..."
  docker compose down --remove-orphans 2>/dev/null || docker-compose down --remove-orphans 2>/dev/null || true
fi

echo "==> Stopping running containers..."
running="$(docker ps -q 2>/dev/null || true)"
if [[ -n "${running}" ]]; then
  # shellcheck disable=SC2086
  docker stop ${running}
else
  echo "    No running containers."
fi

echo "==> Removing stopped containers..."
docker container prune -f

echo "==> Removing unused images..."
docker image prune -af

echo "==> Removing unused networks, volumes, and build cache..."
docker network prune -f
docker volume prune -f
docker builder prune -af 2>/dev/null || true
docker system prune -af --volumes

echo "==> Docker cleanup complete."
docker system df || true
