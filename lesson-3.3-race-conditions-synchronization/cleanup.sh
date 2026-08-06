#!/usr/bin/env bash
# Stop containers and prune unused Docker resources for this workspace.
set -euo pipefail

echo "==> Stopping project-related containers (if any)..."
if command -v docker >/dev/null 2>&1; then
  # Stop all running containers
  if [ "$(docker ps -q 2>/dev/null | wc -l)" -gt 0 ]; then
    docker ps -q | xargs -r docker stop
    echo "Stopped running containers."
  else
    echo "No running containers."
  fi

  # Remove stopped containers
  if [ "$(docker ps -aq 2>/dev/null | wc -l)" -gt 0 ]; then
    docker ps -aq | xargs -r docker rm -f
    echo "Removed containers."
  else
    echo "No containers to remove."
  fi

  echo "==> Pruning unused Docker resources..."
  docker system prune -af --volumes
  docker image prune -af
  echo "Docker cleanup complete."
else
  echo "Docker not installed or not on PATH; skipping container cleanup."
fi

echo "==> Removing local caches (node_modules, venv, pytest, pyc, Istio)..."
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

find . -type d \( -name node_modules -o -name venv -o -name .venv -o -name .pytest_cache -o -name __pycache__ \) -prune -exec rm -rf {} + 2>/dev/null || true
find . -type f \( -name '*.pyc' -o -name '*.pyo' \) -delete 2>/dev/null || true
find . -iname '*istio*' -not -path './.git/*' -exec rm -rf {} + 2>/dev/null || true

echo "Cleanup finished."
