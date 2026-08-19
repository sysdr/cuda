// hello_gpu.cu
// Lesson 4.6 -- your first build. Module 4's closer.
//
// If you've seen a CUDA tutorial before, this filename probably makes
// you expect a kernel. It doesn't have one. Not by accident -- launching
// a kernel deserves Module 5's full attention, not a rushed cameo at
// the tail end of environment setup. What this program actually does
// is say hello the way the last five lessons have been building
// toward: by successfully talking to your GPU through every piece of
// the toolchain at once, and confirming all of it actually works
// together before Module 5 asks it to do real work.
//
// Still no kernel launch, no __global__ function -- the last lesson in
// this course that can say that. Host-side CUDA runtime API only,
// built with CMake, same pattern lesson 4.5 just explained line by line.
#include <cstdio>
#include <cuda_runtime.h>

int main() {
    printf("=======================================================\n");
    printf("  Hello from the host -- GPU Unboxed, lesson 4.6\n");
    printf("=======================================================\n\n");

    // --- everything lesson 4.1-4.5 verified, consolidated into one
    // final report ---
    int device_count = 0;
    cudaError_t count_err = cudaGetDeviceCount(&device_count);
    if (count_err != cudaSuccess || device_count == 0) {
        fprintf(stderr, "No CUDA-capable device reachable: %s\n", cudaGetErrorString(count_err));
        printf("Verification: environment_ready = FAIL\n");
        return 1;
    }

    cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop, 0);

    int runtime_version = 0, driver_version = 0;
    cudaRuntimeGetVersion(&runtime_version);
    cudaDriverGetVersion(&driver_version);

    printf("Part 1: the GPU this whole course targets\n");
    printf("  device:               %s\n", prop.name);
    printf("  compute capability:   %d.%d\n", prop.major, prop.minor);
    printf("  streaming multiprocessors: %d\n", prop.multiProcessorCount);
    printf("  total memory:         %.1f GB\n\n", prop.totalGlobalMem / (1024.0 * 1024.0 * 1024.0));

    printf("Part 2: the toolchain, all four lessons of it, at once\n");
    printf("  CUDA Toolkit (lesson 4.4):      %d.%d\n", runtime_version / 1000, (runtime_version % 1000) / 10);
    printf("  driver headroom (lesson 4.2):   %d.%d\n", driver_version / 1000, (driver_version % 1000) / 10);
    printf("  built via CMake (lesson 4.5):   yes -- this binary came from cmake --build\n\n");

    bool device_ok = (device_count > 0);
    bool toolkit_ok = (runtime_version / 1000 == 13) && ((runtime_version % 1000) / 10 == 3);
    bool driver_ok = (driver_version >= runtime_version);
    bool warp_ok = (prop.warpSize == 32);

    printf("Part 3: the whole checklist, in one place\n");
    printf("  Verification: gpu_reachable = %s\n", device_ok ? "PASS" : "FAIL");
    printf("  Verification: toolkit_is_13_3 = %s\n", toolkit_ok ? "PASS" : "FAIL");
    printf("  Verification: driver_has_headroom = %s\n", driver_ok ? "PASS" : "FAIL");
    printf("  Verification: warp_size_is_32 = %s\n\n", warp_ok ? "PASS" : "FAIL");

    bool all_pass = device_ok && toolkit_ok && driver_ok && warp_ok;

    if (all_pass) {
        printf("=======================================================\n");
        printf("  environment_ready = PASS\n");
        printf("  every check since lesson 4.1 holds, all at once, right now.\n");
        printf("=======================================================\n\n");
        printf("Part 4: what this program deliberately did NOT do\n");
        printf("  no __global__ function. no <<<...>>> launch. that syntax\n");
        printf("  belongs to Module 5, starting with lesson 5.1 -- threads,\n");
        printf("  blocks, and grids. this lesson's job was making sure\n");
        printf("  nothing about your setup gets in the way when it happens.\n");
        printf("  it won't. Module 5 starts clean.\n");
    } else {
        printf("environment_ready = FAIL -- see which check above failed and\n");
        printf("revisit the matching lesson (4.1 device/driver, 4.2 driver\n");
        printf("version, 4.4 toolkit) before continuing to Module 5.\n");
    }

    printf("\nVerification: environment_ready = %s\n", all_pass ? "PASS" : "FAIL");
    return all_pass ? 0 : 1;
}
