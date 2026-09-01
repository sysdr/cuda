#!/usr/bin/env bash
# Stop containers and remove unused Docker resources, plus local dev artifacts.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

echo "==> Cleaning local dev artifacts in $ROOT"

remove_if_exists() {
  local path="$1"
  if [[ -e "$path" ]]; then
    echo "  removing: $path"
    rm -rf "$path"
  fi
}

# node_modules, Python venvs, pytest cache, bytecode
while IFS= read -r -d '' dir; do
  echo "  removing: $dir"
  rm -rf "$dir"
done < <(find "$ROOT" -type d \( \
  -name node_modules \
  -o -name venv \
  -o -name .venv \
  -o -name .pytest_cache \
  -o -name __pycache__ \
\) -not -path "$ROOT/build/*" -print0 2>/dev/null || true)

while IFS= read -r -d '' file; do
  echo "  removing: $file"
  rm -f "$file"
done < <(find "$ROOT" -type f -name '*.pyc' -not -path "$ROOT/build/*" -print0 2>/dev/null || true)

# Istio manifests and directories
while IFS= read -r -d '' item; do
  echo "  removing: $item"
  rm -rf "$item"
done < <(find "$ROOT" \( \
  -type d -name istio-system \
  -o -type f -iname '*istio*' \
\) -not -path "$ROOT/build/*" -print0 2>/dev/null || true)

echo "==> Docker cleanup"

if ! command -v docker >/dev/null 2>&1; then
  echo "  docker not installed; skipping container cleanup"
  exit 0
fi

if ! docker info >/dev/null 2>&1; then
  echo "  docker daemon not running; skipping container cleanup"
  exit 0
fi

echo "  stopping all running containers..."
mapfile -t running < <(docker ps -q 2>/dev/null || true)
if ((${#running[@]} > 0)); then
  docker stop "${running[@]}"
else
  echo "  no running containers"
fi

echo "  removing stopped containers..."
docker container prune -f

echo "  removing unused images..."
docker image prune -a -f

echo "  removing unused volumes..."
docker volume prune -f

echo "  removing unused networks..."
docker network prune -f

echo "  removing build cache (optional)..."
docker builder prune -a -f 2>/dev/null || true

echo "==> Cleanup complete"
