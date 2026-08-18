# Lesson 4.3 -- Installing Visual Studio 2022 and why nvcc needs cl.exe

## Why this lesson has no compiled CUDA code

Same reason as lessons 4.1 and 4.2 -- the CUDA Toolkit isn't installed
yet (that's lesson 4.4). This lesson only needs a plain host C++
compiler, checked independently of anything CUDA-specific.

## On Ubuntu / WSL2 (primary path)

This is usually already done. Run:

```
chmod +x scripts/check_host_compiler.sh
./scripts/check_host_compiler.sh
```

If it fails: `sudo apt update && sudo apt install build-essential`

## On Windows native

Install Visual Studio 2022 Community with the **Desktop development
with C++** workload -- this is the one checkbox that matters. You do
NOT need to open the Visual Studio IDE at any point in this course.

One-line install (PowerShell, run as your normal user):
```
winget install Microsoft.VisualStudio.2022.Community --override "--add Microsoft.VisualStudio.Workload.NativeDesktop --includeRecommended --quiet"
```

Or download from visualstudio.microsoft.com and check "Desktop
development with C++" in the installer's workload list.

Then verify:
```
.\scripts\check_host_compiler.ps1
```

If PowerShell blocks the script: `powershell -ExecutionPolicy Bypass -File .\scripts\check_host_compiler.ps1`

See `expected_output.txt` for the shape of correct output.
