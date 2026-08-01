// compiler_handoff_demo.cu
// Lesson 1.6 -- compiling with GCC and MSVC: what nvcc actually does
// with a .cu file, and what it hands off to the host compiler
// underneath. Module 1's closer.
//
// This file doesn't demonstrate a CUDA runtime concept -- it demonstrates
// the build itself, by printing compiler-defined macros that prove,
// empirically, which host compiler actually processed this file's host
// code. No kernel launch, same as every other Module 1 lesson.
#include <cstdio>
#include "../common/cuda_check.cuh"

int main() {
    printf("Part 1: was this file actually compiled by nvcc?\n");
#ifdef __NVCC__
    printf("  __NVCC__ is defined -- yes, nvcc processed this file\n");
#else
    printf("  __NVCC__ is NOT defined -- this build skipped nvcc entirely\n");
#endif
#ifdef __CUDACC_VER_MAJOR__
    printf("  CUDA compiler version this file was built with: %d.%d\n",
           __CUDACC_VER_MAJOR__, __CUDACC_VER_MINOR__);
#endif

    printf("\nPart 2: which host compiler did nvcc hand this file's host code to?\n");
#if defined(_MSC_VER)
    printf("  MSVC (cl.exe), _MSC_VER = %d\n", _MSC_VER);
#elif defined(__clang__)
    printf("  Clang, version %d.%d\n", __clang_major__, __clang_minor__);
#elif defined(__GNUC__)
    printf("  GCC, version %d.%d\n", __GNUC__, __GNUC_MINOR__);
#else
    printf("  not recognized by this check -- see NOTES.md\n");
#endif
    printf("  nvcc itself never compiles this half of the file. it splits\n");
    printf("  the translation unit and delegates the host portion entirely.\n");

    printf("\nPart 3: which C++ standard was actually active while compiling\n");
    printf("  __cplusplus = %ldL\n", __cplusplus);
    bool cpp17_reported_correctly = (__cplusplus >= 201703L);
    if (cpp17_reported_correctly) {
        printf("  that's C++17 or newer, matching CMAKE_CXX_STANDARD 17\n");
    } else {
        printf("  that's OLDER than C++17 as reported -- on MSVC this almost\n");
        printf("  always means /Zc:__cplusplus was not passed through nvcc's\n");
        printf("  -Xcompiler flag. see NOTES.md and the CMakeLists in this zip.\n");
    }

    printf("\nVerification: cpp17_correctly_reported = %s\n",
           cpp17_reported_correctly ? "PASS" : "FAIL");

    return cpp17_reported_correctly ? 0 : 1;
}
