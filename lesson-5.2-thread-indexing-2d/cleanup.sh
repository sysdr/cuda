#!/usr/bin/env bash
set -euo pipefail

echo "=== Cleanup Script ==="

# --- Remove node_modules, venv, .pytest_cache, __pycache__, .pyc ---
echo "[1/5] Removing node_modules, venv, .pytest_cache, __pycache__, .pyc files..."
find . -type d -name "node_modules" -exec rm -rf {} + 2>/dev/null || true
find . -type d -name "venv" -exec rm -rf {} + 2>/dev/null || true
find . -type d -name ".venv" -exec rm -rf {} + 2>/dev/null || true
find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find . -type f -name "*.pyc" -delete 2>/dev/null || true

# --- Remove Istio files ---
echo "[2/5] Removing Istio-related files..."
find . -type f -name "*.istio*" -delete 2>/dev/null || true
find . -type d -name "istio*" -exec rm -rf {} + 2>/dev/null || true
find . -type f \( -name "virtual-service*.yaml" -o -name "destination-rule*.yaml" -o -name "gateway*.yaml" -o -name "service-entry*.yaml" \) -delete 2>/dev/null || true

# --- Remove CMake build artifacts ---
echo "[3/5] Removing CMake build directory..."
rm -rf build/

# --- Stop Docker containers and clean up Docker resources ---
echo "[4/5] Stopping all Docker containers..."
if command -v docker &>/dev/null; then
    docker stop $(docker ps -aq) 2>/dev/null || true
    echo "       Removing all stopped containers..."
    docker rm $(docker ps -aq) 2>/dev/null || true
    echo "       Removing unused Docker images..."
    docker image prune -af 2>/dev/null || true
    echo "       Removing unused Docker volumes..."
    docker volume prune -f 2>/dev/null || true
    echo "       Removing unused Docker networks..."
    docker network prune -f 2>/dev/null || true
    echo "       Full Docker system prune..."
    docker system prune -af --volumes 2>/dev/null || true
else
    echo "       Docker not found, skipping."
fi

# --- Remove .env files that may contain API keys ---
echo "[5/5] Removing .env files (may contain secrets)..."
find . -type f -name ".env" -delete 2>/dev/null || true
find . -type f -name ".env.*" -delete 2>/dev/null || true
find . -type f -name "*.env" -delete 2>/dev/null || true

echo ""
echo "=== Cleanup complete ==="
