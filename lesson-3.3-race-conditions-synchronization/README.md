# Lesson 3.3 -- Race conditions and synchronization

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
./build/race_conditions_demo
```

## Build -- Windows native

```
cmake -S . -B build -G "Visual Studio 17 2022" -A x64
cmake --build build --config Release --parallel 8
.\build\Release\race_conditions_demo.exe
```

## Seeing the race confirmed by a sanitizer (optional, separate build)

GCC and Clang both support ThreadSanitizer, which detects data races
directly rather than inferring them from wrong output. To try it:

```
g++ -std=c++17 -fsanitize=thread -g src/race_conditions_demo.cu -o tsan_build -lpthread
./tsan_build
```

Expect a detailed race report pointing at the exact `race_counter++`
line. This is a separate, non-CUDA build purely for this demonstration
-- not part of the course's normal CMake build.

See `expected_output.txt` for what a correct run looks like. Part 1's
exact "missing updates" numbers will differ every run by design --
that instability is the point.
