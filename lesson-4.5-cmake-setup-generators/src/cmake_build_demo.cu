// cmake_build_demo.cu
// Lesson 4.5 -- CMake setup and generators. Deliberately the same
// content as lesson 4.4's toolkit_smoke_test.cu -- the C++ isn't new
// here, the build system is. Compiling the identical program two
// different ways (raw nvcc in 4.4, CMake here) and getting the
// identical verified result is the whole point.
//
// Still no kernel launch -- same Phase-1 precedent as every lesson
// since 1.1. Host-side CUDA runtime API only.
#include <cstdio>
#include <cuda_runtime.h>

void print_version(const char* label, int encoded) {
    int major = encoded / 1000;
    int minor = (encoded % 1000) / 10;
    printf("  %-28s %d.%d\n", label, major, minor);
}

int main() {
    printf("Part 1: the same three-number check from lesson 4.4\n");

    int runtime_version = 0;
    cudaError_t rt_err = cudaRuntimeGetVersion(&runtime_version);
    if (rt_err != cudaSuccess) {
        fprintf(stderr, "cudaRuntimeGetVersion failed: %s\n", cudaGetErrorString(rt_err));
        return 1;
    }

    int driver_version = 0;
    cudaError_t drv_err = cudaDriverGetVersion(&driver_version);
    if (drv_err != cudaSuccess) {
        fprintf(stderr, "cudaDriverGetVersion failed: %s\n", cudaGetErrorString(drv_err));
        return 1;
    }

    print_version("nvcc compiled against:", runtime_version);
    print_version("driver actually supports:", driver_version);
    printf("\n");

    printf("Part 2: reachability, same check as before\n");
    int device_count = 0;
    cudaError_t count_err = cudaGetDeviceCount(&device_count);
    if (count_err != cudaSuccess || device_count == 0) {
        fprintf(stderr, "  no CUDA-capable device reachable: %s\n", cudaGetErrorString(count_err));
        printf("Verification: gpu_reachable = FAIL\n");
        return 1;
    }
    cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop, 0);
    printf("  device 0: %s (compute capability %d.%d)\n", prop.name, prop.major, prop.minor);
    printf("Verification: gpu_reachable = PASS\n\n");

    bool is_13_3 = (runtime_version / 1000 == 13) && ((runtime_version % 1000) / 10 == 3);
    bool driver_sufficient = (driver_version >= runtime_version);

    printf("Part 3: what actually changed since lesson 4.4\n");
    printf("  the .cu file is identical. the compile command is not --\n");
    printf("  this binary was produced by cmake --build, not a raw nvcc\n");
    printf("  invocation. same compiler doing the same work underneath,\n");
    printf("  orchestrated differently. if you ran lesson 4.4's version\n");
    printf("  first, these numbers should match exactly.\n");

    printf("\nVerification: toolkit_is_13_3 = %s\n", is_13_3 ? "PASS" : "FAIL");
    printf("Verification: driver_supports_this_runtime = %s\n", driver_sufficient ? "PASS" : "FAIL");

    bool all_pass = is_13_3 && driver_sufficient;
    printf("\nVerification: all_checks = %s\n", all_pass ? "PASS" : "FAIL");
    return all_pass ? 0 : 1;
}
