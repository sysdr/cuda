# check_driver_cuda_version.ps1
# Lesson 4.2 -- driver first, toolkit second. Windows native version.
#
# Reads the "CUDA Version" field from nvidia-smi's own banner -- driver
# capability, not an installed toolkit version. See the .sh version's
# header comment for the full explanation; this script does the same
# check on Windows.

Write-Host "=== What nvidia-smi's CUDA Version field actually means ==="
Write-Host "  nvidia-smi's banner reports a 'CUDA Version' even with zero toolkit"
Write-Host "  installed. That number describes driver capability, not an installed"
Write-Host "  toolkit -- lesson 4.4 installs the actual toolkit and lesson 4.6's"
Write-Host "  'nvcc --version' is what checks THAT number instead."
Write-Host ""

$nvidiaSmiPath = Get-Command nvidia-smi -ErrorAction SilentlyContinue
if (-not $nvidiaSmiPath) {
    Write-Host "nvidia-smi not found -- go back to lesson 4.1 and resolve that first."
    Write-Host "Verification: nvidia_smi_available = FAIL"
    exit 1
}

$rawOutput = nvidia-smi
$cudaVerMatch = $rawOutput | Select-String -Pattern "CUDA Version:\s*([0-9]+\.[0-9]+)"

if (-not $cudaVerMatch) {
    Write-Host "Could not find a 'CUDA Version' field in nvidia-smi's output."
    Write-Host "Verify lesson 4.1's checks passed first."
    Write-Host "Verification: cuda_version_field_found = FAIL"
    exit 1
}

$driverMaxCuda = $cudaVerMatch.Matches[0].Groups[1].Value
Write-Host "  nvidia-smi reports: CUDA Version: $driverMaxCuda"
Write-Host "  this means: your driver can support CUDA Toolkit versions up to $driverMaxCuda"
Write-Host "Verification: cuda_version_field_found = PASS"
Write-Host ""

Write-Host "=== Is that headroom enough for CUDA Toolkit 13.3, this course's target? ==="
$parts = $driverMaxCuda -split '\.'
$major = [int]$parts[0]
$minor = [int]$parts[1]

if (($major -gt 13) -or ($major -eq 13 -and $minor -ge 3)) {
    Write-Host "  $driverMaxCuda >= 13.3 -- your driver has enough headroom for this course's toolkit"
    Write-Host "Verification: driver_supports_cuda_13_3 = PASS"
} else {
    Write-Host "  $driverMaxCuda < 13.3 -- your driver needs updating BEFORE installing"
    Write-Host "  CUDA Toolkit 13.3 in lesson 4.4."
    Write-Host "Verification: driver_supports_cuda_13_3 = FAIL"
}
Write-Host ""

Write-Host "=== Summary: the rule this whole lesson boils down to ==="
Write-Host "  driver first. always. since CUDA 13.1, the Windows toolkit installer"
Write-Host "  no longer bundles or installs the display driver for you -- get a"
Write-Host "  PASS here, from a driver downloaded separately, before lesson 4.4."
