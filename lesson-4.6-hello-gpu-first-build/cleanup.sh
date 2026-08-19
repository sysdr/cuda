#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Cleanup: stop Docker containers and prune Docker resources"
if command -v docker >/dev/null 2>&1; then
  # If a compose file exists in this repo, prefer shutting down that stack.
  if [ -f "${REPO_ROOT}/docker-compose.yml" ]; then
    docker compose -f "${REPO_ROOT}/docker-compose.yml" down -v --remove-orphans || true
  elif [ -f "${REPO_ROOT}/docker-compose.yaml" ]; then
    docker compose -f "${REPO_ROOT}/docker-compose.yaml" down -v --remove-orphans || true
  elif [ -f "${REPO_ROOT}/compose.yml" ]; then
    docker compose -f "${REPO_ROOT}/compose.yml" down -v --remove-orphans || true
  elif [ -f "${REPO_ROOT}/compose.yaml" ]; then
    docker compose -f "${REPO_ROOT}/compose.yaml" down -v --remove-orphans || true
  fi

  # Stop anything still running (best-effort).
  docker ps -q | xargs -r docker stop || true

  # Remove unused containers/images/networks/volumes.
  docker system prune -af --volumes || true
else
  echo "docker not found; skipping Docker cleanup"
fi

echo "==> Cleanup: remove project local caches/artifacts"
shopt -s globstar nullglob

# Node/Python/pytest artifacts
rm -rf ${REPO_ROOT}/**/node_modules
rm -rf ${REPO_ROOT}/**/venv
rm -rf ${REPO_ROOT}/**/.pytest_cache
rm -rf ${REPO_ROOT}/**/__pycache__
rm -f  ${REPO_ROOT}/**/*.pyc

# Istio artifacts (best-effort; deletes any path that starts with 'istio')
rm -rf ${REPO_ROOT}/**/istio*

echo "==> Cleanup complete"

