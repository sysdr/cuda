# Lesson 4.6 -- Your first build: hello_gpu.cu compiled and run

## Requirements

Everything from lessons 4.1 through 4.5, actually working:
- Driver installed and verified (4.1, 4.2)
- Host compiler installed and verified (4.3)
- CUDA Toolkit 13.3 installed (4.4)
- CMake 3.28+ (4.5)

If any of those is still unresolved, this lesson's checklist will tell
you exactly which one.

## Build -- Ubuntu / WSL2 (primary path)

```
cmake -S . -B build -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel 8
./build/hello_gpu
```

## Build -- Windows native

```
cmake -S . -B build -G "Visual Studio 17 2022" -A x64
cmake --build build --config Release --parallel 8
.\build\Release\hello_gpu.exe
```

See `expected_output.txt` for what a fully working environment prints.
If `environment_ready` reads FAIL, the output tells you exactly which
earlier lesson to revisit.
