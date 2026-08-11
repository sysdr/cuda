# Lesson 4.1 -- Checking your GPU before installing anything

## Why this lesson has no CMakeLists.txt

Every other lesson in this course builds with CMake and nvcc. This one
doesn't, on purpose: at this point in Module 4 you likely don't have
the CUDA Toolkit installed yet -- that's lesson 4.4. This lesson only
needs the NVIDIA driver, which you either already have or are about to
install in lesson 4.2.

The two scripts here (`check_gpu.sh` for Ubuntu/WSL2, `check_gpu.ps1`
for Windows native) both call `nvidia-smi` directly and need nothing
else.

## Requirements

- An NVIDIA GPU
- The NVIDIA driver installed (if you don't have it yet, both scripts
  will tell you so clearly and point you to lesson 4.2)

## Run -- Ubuntu / WSL2

```
chmod +x scripts/check_gpu.sh
./scripts/check_gpu.sh
```

WSL2 note: if `nvidia-smi` isn't found inside WSL, the fix is almost
always on the Windows side -- install the driver there first, per
lesson 4.2, then reopen your WSL terminal. Never `apt install
nvidia-driver-XXX` inside WSL itself.

## Run -- Windows native (PowerShell)

```
.\scripts\check_gpu.ps1
```

If PowerShell blocks the script with an execution policy error, run:
```
powershell -ExecutionPolicy Bypass -File .\scripts\check_gpu.ps1
```

See `expected_output.txt` for the shape of correct output. Every
number here reflects your actual hardware and driver, so it will
differ from any fixed reference.
