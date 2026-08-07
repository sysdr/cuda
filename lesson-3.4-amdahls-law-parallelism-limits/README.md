# Lesson 3.4 -- Amdahl's law and parallelism limits

## Requirements

- NVIDIA GPU, compute capability 8.6 (RTX 3050 / 3060 / 2050) or newer --
  not used by this lesson's code, kept only so the build toolchain
  matches the rest of the course
- CUDA Toolkit 13.3 Update 1 (used here only as the build environment)
- CMake 3.28+
- Ubuntu / WSL2: GCC 11+
- Windows native: Visual Studio 2022, "Desktop development with C++" workload

## Build -- Ubuntu / WSL2 (primary path)

```
cmake -S . -B build -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel 8
./build/amdahls_law_demo
```

Build in Release mode -- Part 1 and Part 2's timings need optimizations
enabled to produce a meaningful, consistent parallel fraction.

## Build -- Windows native

```
cmake -S . -B build -G "Visual Studio 17 2022" -A x64
cmake --build build --config Release --parallel 8
.\build\Release\amdahls_law_demo.exe
```

This program spawns up to 8 worker threads. On a machine with fewer
than 8 logical CPU cores, the N=8 row will still run correctly but the
speedup will plateau earlier than on a machine with more cores
available -- that's expected, not a bug.

See `expected_output.txt` for the shape of correct output. All timing
and speedup numbers are hardware-dependent.
