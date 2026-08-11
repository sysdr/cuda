# check_gpu.ps1
# Lesson 4.1 -- checking your GPU before installing anything else.
# Windows native version. Requires only the NVIDIA driver -- no CUDA
# toolkit, no Visual Studio, nothing this course installs later.

Write-Host "=== Part 1: does nvidia-smi even run? ==="
$nvidiaSmiPath = Get-Command nvidia-smi -ErrorAction SilentlyContinue
if (-not $nvidiaSmiPath) {
    Write-Host "  nvidia-smi not found on PATH."
    Write-Host "  The NVIDIA driver is not installed, or its install directory isn't on PATH."
    Write-Host "  Install the driver (see lesson 4.2) before continuing."
    Write-Host ""
    Write-Host "Verification: nvidia_smi_available = FAIL"
    exit 1
}
Write-Host "  nvidia-smi found."
Write-Host "Verification: nvidia_smi_available = PASS"
Write-Host ""

Write-Host "=== Part 2: what GPU and driver does nvidia-smi actually see? ==="
$gpuInfo = nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader
if (-not $gpuInfo) {
    Write-Host "  nvidia-smi ran but returned no GPU."
    Write-Host "Verification: gpu_detected = FAIL"
    exit 1
}
Write-Host "  $gpuInfo"
$parts = $gpuInfo -split ','
$gpuName = $parts[0].Trim()
$driverVersion = $parts[1].Trim()
Write-Host "Verification: gpu_detected = PASS"
Write-Host ""

Write-Host "=== Part 3: is the driver new enough for CUDA 13.3? ==="
$driverMajor = [int]($driverVersion -split '\.')[0]
if ($driverMajor -ge 580) {
    Write-Host "  driver $driverVersion >= 580 -- meets the CUDA 13.3 floor"
    Write-Host "Verification: driver_meets_cuda13_floor = PASS"
} else {
    Write-Host "  driver $driverVersion < 580 -- update the driver before installing CUDA 13.3"
    Write-Host "  see lesson 4.2 for the correct install order (driver first, toolkit second)"
    Write-Host "Verification: driver_meets_cuda13_floor = FAIL"
}
Write-Host ""

Write-Host "=== Part 4: does this GPU's architecture meet CUDA 13's hardware floor? ==="
Write-Host "  CUDA 13.x dropped Maxwell, Pascal, and Volta. Turing (compute capability 7.5)"
Write-Host "  and newer -- Ampere, Ada, Hopper, Blackwell -- remain supported."
Write-Host "  This table covers common cards relevant to this course. It is NOT exhaustive --"
Write-Host "  if your card isn't listed, check NVIDIA's official compute capability list"
Write-Host "  rather than assuming it's fine."
Write-Host ""

$gpuTable = @{
    "RTX 20" = "7.5 (Turing)"
    "GTX 16" = "7.5 (Turing)"
    "RTX 30" = "8.6 (Ampere)"
    "A100"   = "8.0 (Ampere datacenter)"
    "RTX 40" = "8.9 (Ada)"
    "RTX 50" = "10.x/12.x (Blackwell -- verify exact number against NVIDIA docs)"
}

$found = $null
foreach ($key in $gpuTable.Keys) {
    if ($gpuName -like "*$key*") {
        $found = $gpuTable[$key]
        break
    }
}

Write-Host "  detected: $gpuName"
if ($found) {
    Write-Host "  compute capability (from lookup table, not queried): $found"
    Write-Host "Verification: architecture_meets_cuda13_floor = PASS"
} else {
    Write-Host "  not in this lesson's lookup table -- do not assume it's supported."
    Write-Host "  check https://developer.nvidia.com/cuda-gpus for the real answer."
    Write-Host "Verification: architecture_meets_cuda13_floor = UNKNOWN (not a FAIL -- just not looked up)"
}
Write-Host ""

Write-Host "=== Summary ==="
Write-Host "If Parts 1-3 all show PASS, and Part 4 shows PASS or a confirmed"
Write-Host "compute capability of 7.5 or higher from NVIDIA's own page, you're"
Write-Host "clear to continue to lesson 4.2 (driver-first install ordering) and"
Write-Host "lesson 4.4 (installing CUDA Toolkit 13.3)."
