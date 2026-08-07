#!/usr/bin/env bash
# Stop containers and prune unused Docker resources for this machine.
set -euo pipefail

echo "==> Project junk cleanup (node_modules, venvs, caches, Istio)"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

find "$ROOT" -type d \( -name node_modules -o -name venv -o -name .venv -o -name .pytest_cache -o -name __pycache__ \) -prune -print -exec rm -rf {} + 2>/dev/null || true
find "$ROOT" -type f \( -name '*.pyc' -o -name '*.pyo' \) -print -delete 2>/dev/null || true
find "$ROOT" -iname '*istio*' -print -exec rm -rf {} + 2>/dev/null || true

if ! command -v docker >/dev/null 2>&1; then
  echo "==> Docker not installed; skipping container/image cleanup."
  echo "==> Done."
  exit 0
fi

echo "==> Stopping all running containers"
if [ "$(docker ps -q | wc -l)" -gt 0 ]; then
  docker stop $(docker ps -q)
else
  echo "    (none running)"
fi

echo "==> Removing all containers"
if [ "$(docker ps -aq | wc -l)" -gt 0 ]; then
  docker rm -f $(docker ps -aq)
else
  echo "    (none present)"
fi

echo "==> Removing unused images, networks, volumes, and build cache"
docker system prune -af --volumes

echo "==> Docker disk usage after cleanup"
docker system df || true

echo "==> Done."
