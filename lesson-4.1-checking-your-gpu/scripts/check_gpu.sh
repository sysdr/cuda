#!/usr/bin/env bash
# check_gpu.sh
# Lesson 4.1 -- checking your GPU before installing anything else.
# Ubuntu / WSL2 version. Requires only the NVIDIA driver -- no CUDA
# toolkit, no compiler, nothing this course installs later. If this
# script fails, nothing past this point in Module 4 will work either,
# so it's worth running first and trusting its answer.
set -uo pipefail

echo "=== Part 1: does nvidia-smi even run? ==="
if ! command -v nvidia-smi &> /dev/null; then
    echo "  nvidia-smi not found on PATH."
    echo "  On native Ubuntu: the NVIDIA driver isn't installed. Install it before continuing."
    echo "  On WSL2: the driver lives on the WINDOWS side, not inside WSL. Install the"
    echo "  driver on Windows first (see lesson 4.2), then reopen this WSL terminal --"
    echo "  do NOT run 'apt install nvidia-driver-XXX' inside WSL itself."
    echo ""
    echo "Verification: nvidia_smi_available = FAIL"
    exit 1
fi
echo "  nvidia-smi found."
echo "Verification: nvidia_smi_available = PASS"
echo ""

echo "=== Part 2: what GPU and driver does nvidia-smi actually see? ==="
GPU_INFO=$(nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader 2>/dev/null)
if [ -z "$GPU_INFO" ]; then
    echo "  nvidia-smi ran but returned no GPU. Passthrough or driver problem."
    echo "Verification: gpu_detected = FAIL"
    exit 1
fi
echo "  $GPU_INFO"
GPU_NAME=$(echo "$GPU_INFO" | cut -d',' -f1 | xargs)
DRIVER_VERSION=$(echo "$GPU_INFO" | cut -d',' -f2 | xargs)
echo "Verification: gpu_detected = PASS"
echo ""

echo "=== Part 3: is the driver new enough for CUDA 13.3? ==="
# CUDA 13.3 requires driver R580 or later. Compare the major version number.
DRIVER_MAJOR=$(echo "$DRIVER_VERSION" | cut -d'.' -f1)
if [ "$DRIVER_MAJOR" -ge 580 ] 2>/dev/null; then
    echo "  driver $DRIVER_VERSION >= 580 -- meets the CUDA 13.3 floor"
    echo "Verification: driver_meets_cuda13_floor = PASS"
else
    echo "  driver $DRIVER_VERSION < 580 -- update the driver before installing CUDA 13.3"
    echo "  see lesson 4.2 for the correct install order (driver first, toolkit second)"
    echo "Verification: driver_meets_cuda13_floor = FAIL"
fi
echo ""

echo "=== Part 4: does this GPU's architecture meet CUDA 13's hardware floor? ==="
echo "  CUDA 13.x dropped Maxwell, Pascal, and Volta. Turing (compute capability 7.5)"
echo "  and newer -- Ampere, Ada, Hopper, Blackwell -- remain supported."
echo "  This table covers common cards relevant to this course. It is NOT exhaustive --"
echo "  if your card isn't listed, check NVIDIA's official compute capability list"
echo "  rather than assuming it's fine."
echo ""

# Small, explicitly incomplete lookup table -- substring match against
# nvidia-smi's reported name. Extend with entries verified against
# NVIDIA's own documentation only, never guessed.
declare -A GPU_TABLE=(
    ["RTX 20"]="7.5 (Turing)"
    ["GTX 16"]="7.5 (Turing)"
    ["RTX 30"]="8.6 (Ampere)"
    ["A100"]="8.0 (Ampere datacenter)"
    ["RTX 40"]="8.9 (Ada)"
    ["RTX 50"]="10.x/12.x (Blackwell -- verify exact number against NVIDIA docs)"
)

FOUND=""
for key in "${!GPU_TABLE[@]}"; do
    if [[ "$GPU_NAME" == *"$key"* ]]; then
        FOUND="${GPU_TABLE[$key]}"
        break
    fi
done

if [ -n "$FOUND" ]; then
    echo "  detected: $GPU_NAME"
    echo "  compute capability (from lookup table, not queried): $FOUND"
    echo "Verification: architecture_meets_cuda13_floor = PASS"
else
    echo "  detected: $GPU_NAME"
    echo "  not in this lesson's lookup table -- do not assume it's supported."
    echo "  check https://developer.nvidia.com/cuda-gpus for the real answer."
    echo "Verification: architecture_meets_cuda13_floor = UNKNOWN (not a FAIL -- just not looked up)"
fi
echo ""

echo "=== Summary ==="
echo "If Parts 1-3 all show PASS, and Part 4 shows PASS or a confirmed"
echo "compute capability of 7.5 or higher from NVIDIA's own page, you're"
echo "clear to continue to lesson 4.2 (driver-first install ordering) and"
echo "lesson 4.4 (installing CUDA Toolkit 13.3)."
