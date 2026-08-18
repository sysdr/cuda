# check_host_compiler.ps1
# Lesson 4.3 -- confirming a host C++ compiler exists before installing
# the CUDA Toolkit. Windows native version.
#
# cl.exe is NOT normally on PATH in an ordinary PowerShell session --
# it only becomes available inside a Developer Command Prompt, or after
# running vcvars64.bat. Checking "is cl.exe on PATH" from a plain
# terminal gives a false negative even on a correctly installed system.
# vswhere.exe -- a real tool Microsoft ships with every VS2022 install --
# is the correct way to check without requiring a Developer Prompt.

Write-Host "=== Locating vswhere.exe (ships with Visual Studio 2022) ==="
$vswherePath = "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe"

if (-not (Test-Path $vswherePath)) {
    Write-Host "  vswhere.exe not found -- Visual Studio 2022 is likely not installed yet."
    Write-Host "  fix: winget install Microsoft.VisualStudio.2022.Community --override `"--add Microsoft.VisualStudio.Workload.NativeDesktop --includeRecommended --quiet`""
    Write-Host "  or download from visualstudio.microsoft.com and select"
    Write-Host "  'Desktop development with C++' during install."
    Write-Host "Verification: visual_studio_found = FAIL"
    exit 1
}
Write-Host "  found: $vswherePath"
Write-Host "Verification: visual_studio_found = PASS"
Write-Host ""

Write-Host "=== Does the install include the C++ build tools nvcc needs? ==="
$vcPath = & $vswherePath -latest -products * `
    -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
    -property installationPath

if (-not $vcPath) {
    Write-Host "  Visual Studio is installed, but the 'Desktop development with"
    Write-Host "  C++' workload is NOT. This is the single most common Windows"
    Write-Host "  setup mistake in this course."
    Write-Host "  fix: open Visual Studio Installer -> Modify -> check"
    Write-Host "  'Desktop development with C++' -> Modify. You never need to"
    Write-Host "  actually open the Visual Studio IDE itself for this course."
    Write-Host "Verification: cpp_workload_installed = FAIL"
    exit 1
}
Write-Host "  found C++ build tools at: $vcPath"
Write-Host "Verification: cpp_workload_installed = PASS"
Write-Host ""

Write-Host "=== Locating cl.exe itself under that install ==="
$clSearch = Get-ChildItem -Path "$vcPath\VC\Tools\MSVC" -Filter "cl.exe" -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -like "*Hostx64\x64*" } |
    Select-Object -First 1

if ($clSearch) {
    Write-Host "  found: $($clSearch.FullName)"
    Write-Host "Verification: cl_exe_found = PASS"
} else {
    Write-Host "  C++ workload reports installed, but cl.exe wasn't found in the"
    Write-Host "  expected location. This is unusual -- worth a Visual Studio"
    Write-Host "  Installer repair before continuing."
    Write-Host "Verification: cl_exe_found = FAIL"
}
Write-Host ""

Write-Host "=== Summary ==="
Write-Host "  nvcc never compiles your host code itself (lesson 1.6) -- it hands"
Write-Host "  that half of every .cu file to cl.exe, found above. You do NOT need"
Write-Host "  to ever open the Visual Studio IDE for this course -- CMake and nvcc"
Write-Host "  call cl.exe directly once it's installed."
