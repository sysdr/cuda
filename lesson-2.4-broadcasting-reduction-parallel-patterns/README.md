# Lesson 2.4 -- Broadcasting and reduction as parallel patterns

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
./build/broadcast_reduction_demo
```

## Build -- Windows native

```
cmake -S . -B build -G "Visual Studio 17 2022" -A x64
cmake --build build --config Release --parallel 8
.\build\Release\broadcast_reduction_demo.exe
```

See `expected_output.txt` for what a correct run looks like. Every
number in this lesson is deterministic and small -- no
<!-- MEASURED --> placeholders needed anywhere in this one.
