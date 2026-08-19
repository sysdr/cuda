#!/usr/bin/env bash
# cleanup.sh — stop containers, prune Docker, remove local build/cache artifacts.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

echo "==> Stopping all running Docker containers..."
if command -v docker >/dev/null 2>&1; then
  mapfile -t running < <(docker ps -q 2>/dev/null || true)
  if ((${#running[@]})); then
    docker stop "${running[@]}"
  else
    echo "    No running containers."
  fi

  echo "==> Removing stopped containers..."
  mapfile -t stopped < <(docker ps -aq 2>/dev/null || true)
  if ((${#stopped[@]})); then
    docker rm -f "${stopped[@]}"
  else
    echo "    No containers to remove."
  fi

  echo "==> Pruning unused Docker resources (images, networks, build cache)..."
  docker system prune -af --volumes
else
  echo "    Docker not installed; skipping container cleanup."
fi

echo "==> Removing node_modules, venv, pytest cache, pyc, and Istio artifacts..."
find "$ROOT" \
  \( -name node_modules -o -name venv -o -name .pytest_cache -o -name __pycache__ \) \
  -type d -prune -exec rm -rf {} + 2>/dev/null || true

find "$ROOT" -name '*.pyc' -type f -delete 2>/dev/null || true
find "$ROOT" -iname '*istio*' \( -type f -o -type d \) -exec rm -rf {} + 2>/dev/null || true

echo "==> Removing compiled lesson binaries..."
rm -f "$ROOT/cmake_build_demo" "$ROOT/cmake_build_demo.exe"
rm -rf "$ROOT/build"

echo "==> Cleanup complete."
