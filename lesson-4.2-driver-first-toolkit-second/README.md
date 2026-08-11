# Lesson 4.2 -- Driver first, toolkit second

## Why this lesson has no compiled code

Same reason as lesson 4.1: at this point you still don't have the CUDA
Toolkit installed -- that's lesson 4.4, coming after this one on
purpose. This lesson works entirely through `nvidia-smi`'s own banner
output.

## Requirements

- An NVIDIA GPU
- The NVIDIA driver installed (lesson 4.1's checks should already show
  PASS before you run this one)

## Run -- Ubuntu / WSL2

```
chmod +x scripts/check_driver_cuda_version.sh
./scripts/check_driver_cuda_version.sh
```

## Run -- Windows native (PowerShell)

```
.\scripts\check_driver_cuda_version.ps1
```

If PowerShell blocks the script:
```
powershell -ExecutionPolicy Bypass -File .\scripts\check_driver_cuda_version.ps1
```

## Where to actually get the driver

- **Windows native:** download directly from
  https://www.nvidia.com/Download/index.aspx -- do NOT expect the CUDA
  Toolkit installer to provide it. Since CUDA 13.1 it no longer bundles
  the driver.
- **Ubuntu (native):** `sudo ubuntu-drivers autoinstall` is the
  simplest path, or `sudo apt install nvidia-driver-580` (or later) for
  an explicit version. Reboot after installing.
- **WSL2:** install the driver on the **Windows** host using the same
  link as "Windows native" above. Never install a driver package inside
  the WSL2 Linux environment itself -- see lesson 4.1's diagram 3 for
  why that specific mistake breaks GPU passthrough.

See `expected_output.txt` for the shape of correct output. The exact
CUDA Version number reflects your actual driver.
