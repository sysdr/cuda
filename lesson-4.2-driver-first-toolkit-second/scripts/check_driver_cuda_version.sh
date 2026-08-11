#!/usr/bin/env bash
# check_driver_cuda_version.sh
# Lesson 4.2 -- driver first, toolkit second. Ubuntu / WSL2 version.
#
# This script reads the "CUDA Version" field from nvidia-smi's own
# banner -- a number that trips up almost everyone the first time they
# see it, because it looks like "the CUDA version I have installed."
# It isn't. It's the maximum CUDA version your DRIVER can support, and
# it appears even if no CUDA Toolkit is installed at all.
set -uo pipefail

echo "=== What nvidia-smi's CUDA Version field actually means ==="
echo "  nvidia-smi's banner reports a 'CUDA Version' even with zero toolkit"
echo "  installed. That number describes driver capability, not an installed"
echo "  toolkit -- lesson 4.4 installs the actual toolkit and lesson 4.6's"
echo "  'nvcc --version' is what checks THAT number instead."
echo ""

if ! command -v nvidia-smi &> /dev/null; then
    echo "nvidia-smi not found -- go back to lesson 4.1 and resolve that first."
    echo "Verification: nvidia_smi_available = FAIL"
    exit 1
fi

RAW_OUTPUT=$(nvidia-smi 2>/dev/null)
CUDA_VER_LINE=$(echo "$RAW_OUTPUT" | grep -o "CUDA Version: [0-9]*\.[0-9]*")

if [ -z "$CUDA_VER_LINE" ]; then
    echo "Could not find a 'CUDA Version' field in nvidia-smi's output."
    echo "This can happen on some minimal/headless driver installs -- if so,"
    echo "the driver may still be too old or incomplete. Verify with lesson 4.1's"
    echo "checks first."
    echo "Verification: cuda_version_field_found = FAIL"
    exit 1
fi

DRIVER_MAX_CUDA=$(echo "$CUDA_VER_LINE" | grep -o "[0-9]*\.[0-9]*")
echo "  nvidia-smi reports: $CUDA_VER_LINE"
echo "  this means: your driver can support CUDA Toolkit versions up to $DRIVER_MAX_CUDA"
echo "Verification: cuda_version_field_found = PASS"
echo ""

echo "=== Is that headroom enough for CUDA Toolkit 13.3, this course's target? ==="
DRIVER_MAX_MAJOR=$(echo "$DRIVER_MAX_CUDA" | cut -d'.' -f1)
DRIVER_MAX_MINOR=$(echo "$DRIVER_MAX_CUDA" | cut -d'.' -f2)

if [ "$DRIVER_MAX_MAJOR" -gt 13 ] || { [ "$DRIVER_MAX_MAJOR" -eq 13 ] && [ "$DRIVER_MAX_MINOR" -ge 3 ]; }; then
    echo "  $DRIVER_MAX_CUDA >= 13.3 -- your driver has enough headroom for this course's toolkit"
    echo "Verification: driver_supports_cuda_13_3 = PASS"
else
    echo "  $DRIVER_MAX_CUDA < 13.3 -- your driver needs updating BEFORE installing"
    echo "  CUDA Toolkit 13.3 in lesson 4.4. Installing the toolkit first, on an"
    echo "  older driver, is exactly the ordering mistake this lesson exists to prevent."
    echo "Verification: driver_supports_cuda_13_3 = FAIL"
fi
echo ""

echo "=== Summary: the rule this whole lesson boils down to ==="
echo "  driver first. always. the toolkit installer does not reliably fix a"
echo "  missing or outdated driver for you -- since CUDA 13.1, the Windows"
echo "  installer doesn't even try. get a PASS here before lesson 4.4."
