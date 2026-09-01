# Lesson 5.3 -- Launching a kernel: the <<<grid, block>>> syntax

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
./build/launch_syntax_demo
```

## Build -- Windows native

```
cmake -S . -B build -G "Visual Studio 17 2022" -A x64
cmake --build build --config Release --parallel 8
.\build\Release\launch_syntax_demo.exe
```

See `expected_output.txt` for what a correct run looks like. Every
number here is deterministic.
