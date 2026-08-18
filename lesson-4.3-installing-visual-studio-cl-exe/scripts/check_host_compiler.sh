#!/usr/bin/env bash
# check_host_compiler.sh
# Lesson 4.3 -- confirming a host C++ compiler exists before installing
# the CUDA Toolkit. Ubuntu / WSL2 version. On this platform, this is
# usually already done -- GCC ships with most Ubuntu installs or is one
# apt command away. No CUDA Toolkit needed for this check either.
set -uo pipefail

echo "=== Does a host C++ compiler exist on this system? ==="
if ! command -v g++ &> /dev/null; then
    echo "  g++ not found."
    echo "  fix: sudo apt update && sudo apt install build-essential"
    echo "Verification: host_compiler_found = FAIL"
    exit 1
fi

GXX_VERSION_LINE=$(g++ --version | head -n1)
GXX_MAJOR=$(g++ -dumpversion | cut -d'.' -f1)
echo "  found: $GXX_VERSION_LINE"
echo "Verification: host_compiler_found = PASS"
echo ""

echo "=== Is it new enough for CUDA 13.3's C++17 requirement? ==="
if [ "$GXX_MAJOR" -ge 11 ]; then
    echo "  g++ $GXX_MAJOR >= 11 -- meets this course's minimum"
    echo "Verification: host_compiler_version_ok = PASS"
else
    echo "  g++ $GXX_MAJOR < 11 -- upgrade before lesson 4.4"
    echo "  fix: sudo apt install g++-11 (or later)"
    echo "Verification: host_compiler_version_ok = FAIL"
fi
echo ""

echo "=== Summary ==="
echo "  nvcc never compiles your host code itself (lesson 1.6) -- it hands"
echo "  that half of every .cu file to exactly this compiler. On Ubuntu and"
echo "  WSL2 that's almost always already sorted, which is one real advantage"
echo "  of this course's primary platform over Windows native."
