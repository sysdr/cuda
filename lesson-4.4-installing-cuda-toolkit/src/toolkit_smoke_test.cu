// toolkit_smoke_test.cu
// Lesson 4.4 -- installing CUDA Toolkit 13.3 Update 1 and verifying it
// actually works. Compiled directly with nvcc, no CMake yet -- that's
// lesson 4.5's subject. No kernel launch either -- still Phase 1, same
// scoping as every lesson since 1.1. This file uses only host-side
// CUDA runtime API calls, the same category as lesson 3.1's device
// query, which is enough to prove nvcc, the CUDA runtime library, and
// the linker all actually work together end to end.
//
// The real point of this file: there are THREE different numbers all
// called "the CUDA version," and this program checks two of them
// against each other. Lesson 4.2 already covered the first one
// (nvidia-smi's driver headroom number). This lesson adds the other two.
#include <cstdio>
#include <cuda_runtime.h>

void print_version(const char* label, int encoded) {
    int major = encoded / 1000;
    int minor = (encoded % 1000) / 10;
    printf("  %-28s %d.%d\n", label, major, minor);
}

int main() {
    printf("Part 1: three numbers, all called \"the CUDA version\"\n");

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
    printf("  (compare 'driver actually supports' against lesson 4.2's\n");
    printf("  nvidia-smi CUDA Version number -- they should match)\n\n");

    printf("Part 2: does the runtime library actually reach a GPU?\n");
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

    printf("Part 3: is the installed toolkit actually 13.3, as this course targets?\n");
    bool is_13_3 = (runtime_version / 1000 == 13) && ((runtime_version % 1000) / 10 == 3);
    printf("  Verification: toolkit_is_13_3 = %s\n\n", is_13_3 ? "PASS" : "FAIL");

    printf("Part 4: does the driver have enough headroom for what nvcc just compiled?\n");
    bool driver_sufficient = (driver_version >= runtime_version);
    printf("  Verification: driver_supports_this_runtime = %s\n",
           driver_sufficient ? "PASS" : "FAIL");
    if (!driver_sufficient) {
        printf("  driver version is BELOW the runtime nvcc compiled against --\n");
        printf("  this is the exact ordering mistake lesson 4.2 exists to prevent.\n");
    }

    bool all_pass = is_13_3 && driver_sufficient;
    printf("\nVerification: all_checks = %s\n", all_pass ? "PASS" : "FAIL");
    return all_pass ? 0 : 1;
}
