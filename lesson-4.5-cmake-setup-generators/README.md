# Lesson 4.5 -- CMake setup and the Visual Studio 17 2022 generator

## Install CMake 3.28+

**Ubuntu / WSL2** -- the default apt package on many Ubuntu releases is
older than 3.28. The simplest reliable fix:
```
pip install --upgrade cmake
```
(Or add Kitware's official apt repository for a system-wide install --
see cmake.org/download for current instructions.)

**Windows native:**
```
winget install Kitware.CMake
```

Verify either platform: `cmake --version`

## Build -- Ubuntu / WSL2 (Unix Makefiles generator)

```
cmake -S . -B build -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel 8
./build/cmake_build_demo
```

## Build -- Windows native (Visual Studio 17 2022 generator)

```
cmake -S . -B build -G "Visual Studio 17 2022" -A x64
cmake --build build --config Release --parallel 8
.\build\Release\cmake_build_demo.exe
```

`-S .` is the source directory (where this CMakeLists.txt lives).
`-B build` is a separate build directory CMake creates and fills with
generated build files -- an out-of-source build, kept deliberately
apart from your actual source so it can be deleted and rebuilt from
scratch at any time.

See `expected_output.txt` for what a correct run looks like. If you
completed lesson 4.4 first, these numbers should match exactly --
same compiler, same toolkit, different orchestration.
