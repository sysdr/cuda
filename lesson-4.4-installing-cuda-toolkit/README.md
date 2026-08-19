# Lesson 4.4 -- Installing CUDA Toolkit 13.3 Update 1

## Why this lesson compiles with a raw nvcc command, not CMake

CMake setup is lesson 4.5's job. This lesson only needs to prove the
toolkit itself installed correctly, so it compiles directly:

```
nvcc src/toolkit_smoke_test.cu -o toolkit_smoke_test
```

## Install the toolkit -- Ubuntu / WSL2 (primary path)

Use NVIDIA's official apt repository, and install the **toolkit
package specifically** -- not the `cuda` meta-package, which can also
try to touch your driver. You already installed and verified the
driver separately in lesson 4.2; keep it that way.

```
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt update
sudo apt install cuda-toolkit-13-3
```

Then add it to PATH -- apt does not do this for you automatically:

```
echo 'export PATH=/usr/local/cuda-13.3/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda-13.3/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc
```

Verify: `nvcc --version`

## Install the toolkit -- Windows native

Download the CUDA Toolkit 13.3 Update 1 installer from
developer.nvidia.com/cuda-downloads. Choose a **custom** install. Since
CUDA 13.1, the installer no longer bundles the display driver (lesson
4.2) -- if it offers a driver component, you can leave it unchecked,
since you already have a working driver.

Verify in a new PowerShell window: `nvcc --version`

## Build and run this lesson's check

**Ubuntu / WSL2**
```
nvcc src/toolkit_smoke_test.cu -o toolkit_smoke_test
./toolkit_smoke_test
```

**Windows native**
```
nvcc src\toolkit_smoke_test.cu -o toolkit_smoke_test.exe
.\toolkit_smoke_test.exe
```

See `expected_output.txt` for the shape of correct output.
