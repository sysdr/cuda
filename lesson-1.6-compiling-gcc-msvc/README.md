# Lesson 1.6 -- Compiling with GCC and MSVC

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
./build/compiler_handoff_demo
```

WSL2 note: driver lives on the Windows host. Install it there, confirm
`nvidia-smi` works inside WSL, and only install the CUDA toolkit itself
inside the Linux environment.

## Build -- Windows native

```
cmake -S . -B build -G "Visual Studio 17 2022" -A x64
cmake --build build --config Release --parallel 8
.\build\Release\compiler_handoff_demo.exe
```

## Seeing the actual compiler commands nvcc runs

To see exactly what nvcc hands to the host compiler, build with
`--verbose` (or `-v`) added to the compile line. Add this temporarily to
the target's compile options, rebuild once, and read the printed command
lines -- you'll see nvcc's own invocation, then a completely separate
invocation of `cl.exe` or `g++`/`gcc` for the host-code translation unit.
Remove the flag afterward; it's extremely noisy for normal use.

See `expected_output.txt` for what a correct run looks like.
