# Lesson 1.4 -- Array of structs vs struct of arrays

## Requirements

- NVIDIA GPU, compute capability 8.6 (RTX 3050 / 3060 / 2050) or newer --
  needed here only for the cudaMalloc calls in Part 5, not for the
  benchmark itself, which runs entirely on the CPU
- NVIDIA driver R580 or later
- CUDA Toolkit 13.3 Update 1
- CMake 3.28+
- Ubuntu / WSL2: GCC 11+
- Windows native: Visual Studio 2022, "Desktop development with C++" workload

## Build -- Ubuntu / WSL2 (primary path)

```
cmake -S . -B build -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel 8
./build/aos_vs_soa_demo
```

Build in Release mode. In a debug build the compiler won't optimize the
inner loops and the AoS/SoA timing difference will be much smaller or
absent -- that's an artifact of unoptimized code, not a real finding.

WSL2 note: driver lives on the Windows host. Install it there, confirm
`nvidia-smi` works inside WSL, and only install the CUDA toolkit itself
inside the Linux environment.

## Build -- Windows native

```
cmake -S . -B build -G "Visual Studio 17 2022" -A x64
cmake --build build --config Release --parallel 8
.\build\Release\aos_vs_soa_demo.exe
```

See `expected_output.txt` for what a correct run looks like.
