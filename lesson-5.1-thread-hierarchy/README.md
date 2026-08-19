# Lesson 5.1 -- Threads, blocks, and grids: the three-level hierarchy

The first kernel launch in this course. Everything from lesson 1.1
through 4.6 was preparation for this file.

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
./build/thread_hierarchy_demo
```

## Build -- Windows native

```
cmake -S . -B build -G "Visual Studio 17 2022" -A x64
cmake --build build --config Release --parallel 8
.\build\Release\thread_hierarchy_demo.exe
```

See `expected_output.txt` for what a correct run looks like. This
program's core numbers (0, 255, 256, 4095) are deterministic and
should match exactly on any working install.
