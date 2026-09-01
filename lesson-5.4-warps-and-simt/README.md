# Lesson 5.4 -- Warps and SIMT

## Requirements

- NVIDIA GPU, compute capability 8.6 (RTX 3050 / 3060 / 2050) or newer
- NVIDIA driver R580 or later
- CUDA Toolkit 13.3 Update 1
- CMake 3.28+
- Ubuntu / WSL2: GCC 11+
- Windows native: Visual Studio 2022, "Desktop development with C++" workload

## Build -- Ubuntu / WSL2 (primary path)

```
cmake -S . -B build -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel 8
./build/warp_divergence_demo
```

## Build -- Windows native

```
cmake -S . -B build -G "Visual Studio 17 2022" -A x64
cmake --build build --config Release --parallel 8
.\build\Release\warp_divergence_demo.exe
```

Build in Release mode -- an unoptimized build can distort the timing
comparison this lesson depends on.

See `expected_output.txt` for what a correct run looks like. Timing
numbers are hardware-dependent; correctness checks are not.
