#!/usr/bin/env bash
# Stop containers and prune unused Docker resources for this workspace.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "==> Project root: $ROOT"

echo "==> Removing local junk (node_modules, venv, caches, Istio, .pyc)..."
find "$ROOT" \( \
  -type d \( -name node_modules -o -name venv -o -name .venv -o -name .pytest_cache \
            -o -name __pycache__ -o -name istio -o -name 'istio-*' \) \
  -o -type f \( -name '*.pyc' -o -name '*.pyo' \) \
\) -print -exec rm -rf {} + 2>/dev/null || true

if ! command -v docker >/dev/null 2>&1; then
  echo "==> Docker is not installed or not on PATH; skipping container cleanup."
  echo "==> Done."
  exit 0
fi

if ! docker info >/dev/null 2>&1; then
  echo "==> Docker daemon is not reachable; skipping container cleanup."
  echo "==> Done."
  exit 0
fi

echo "==> Stopping compose stacks (if any)..."
if docker compose version >/dev/null 2>&1; then
  while IFS= read -r dir; do
    [ -z "$dir" ] && continue
    echo "    compose down in: $dir"
    (cd "$dir" && docker compose down --remove-orphans) || true
  done < <(find "$ROOT" -maxdepth 3 \( -name 'compose.yaml' -o -name 'compose.yml' -o -name 'docker-compose.yml' -o -name 'docker-compose.yaml' \) -printf '%h\n' | sort -u)
fi

echo "==> Stopping all running containers..."
ids="$(docker ps -q || true)"
if [ -n "$ids" ]; then
  docker stop $ids || true
else
  echo "    no running containers"
fi

echo "==> Removing all containers..."
ids="$(docker ps -aq || true)"
if [ -n "$ids" ]; then
  docker rm -f $ids || true
else
  echo "    no containers to remove"
fi

echo "==> Pruning unused images, volumes, networks, and build cache..."
docker system prune -af --volumes || true
docker builder prune -af || true

echo "==> Remaining containers:"
docker ps -a || true
echo "==> Remaining images:"
docker images || true

echo "==> Done."
