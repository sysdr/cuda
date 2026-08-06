# Lesson 3.2 -- Processes, threads, and what "thread" means on a GPU

## Requirements

- NVIDIA GPU, compute capability 8.6 (RTX 3050 / 3060 / 2050) or newer --
  not used by this lesson's code, kept only so the build toolchain
  matches the rest of the course
- CUDA Toolkit 13.3 Update 1 (used here only as the build environment)
- CMake 3.28+
- Ubuntu / WSL2: GCC 11+ (pthread is handled automatically via CMake's
  Threads package, no manual -pthread flag needed)
- Windows native: Visual Studio 2022, "Desktop development with C++" workload

## Build -- Ubuntu / WSL2 (primary path)

```
cmake -S . -B build -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel 8
./build/threads_processes_demo
```

## Build -- Windows native

```
cmake -S . -B build -G "Visual Studio 17 2022" -A x64
cmake --build build --config Release --parallel 8
.\build\Release\threads_processes_demo.exe
```

See `expected_output.txt` for what a correct run looks like. Part 2's
timing will vary by machine; Part 1's checks should not.
