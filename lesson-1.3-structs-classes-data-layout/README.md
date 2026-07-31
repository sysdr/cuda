# Lesson 1.3 -- Structs, classes, and data layout in memory

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
./build/struct_layout_demo
```

WSL2 note: driver lives on the Windows host. Install it there, confirm
`nvidia-smi` works inside WSL, and only install the CUDA toolkit itself
inside the Linux environment.

## Build -- Windows native

```
cmake -S . -B build -G "Visual Studio 17 2022" -A x64
cmake --build build --config Release --parallel 8
.\build\Release\struct_layout_demo.exe
```

Note: this lesson's verification happens at compile time via
`static_assert`, not at runtime. If the build fails with a
`static_assert` error mentioning struct layout, see NOTES.md before
assuming your toolchain is broken.

See `expected_output.txt` for what a correct run looks like.
