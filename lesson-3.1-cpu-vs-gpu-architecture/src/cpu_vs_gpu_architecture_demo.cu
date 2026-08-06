// cpu_vs_gpu_architecture_demo.cu
// Lesson 3.1 -- CPU vs GPU architecture overview. Module 3's opener,
// and the first lesson in this course that queries your actual GPU's
// real numbers instead of asserting a number in prose and hoping it's
// still accurate. No kernel launch -- Module 3 is still Phase 1, same
// scoping used throughout Modules 1 and 2. cudaGetDeviceProperties is
// a legitimate, kernel-free CUDA API, and this is the natural place
// for it.
#include <cstdio>
#include "../common/cuda_check.cuh"

// Cores per SM depends on the architecture generation -- this is NOT
// derivable from compute capability by a single formula, it's a fact
// NVIDIA has changed release to release. This table covers the
// architectures directly relevant to this course plus a few common
// others. It is not exhaustive on purpose -- an unknown architecture
// prints "unknown" rather than a guessed number.
int cores_per_sm(int major, int minor) {
    if (major == 8 && minor == 6) return 128; // Ampere consumer (GA10x) -- RTX 30-series, this course's target
    if (major == 8 && minor == 9) return 128; // Ada consumer (RTX 40-series)
    if (major == 8 && minor == 0) return 64;  // Ampere datacenter (A100, GA100)
    if (major == 7 && minor == 5) return 64;  // Turing
    if (major == 7 && minor == 0) return 64;  // Volta
    if (major == 6) return 128;               // Pascal, most consumer variants
    return -1; // unknown -- do not guess
}

int main() {
    int device_count = 0;
    CUDA_CHECK(cudaGetDeviceCount(&device_count));
    if (device_count == 0) {
        fprintf(stderr, "No CUDA-capable device found.\n");
        return 1;
    }

    cudaDeviceProp prop;
    CUDA_CHECK(cudaGetDeviceProperties(&prop, 0));

    // clockRate / memoryClockRate were removed from cudaDeviceProp in CUDA 13;
    // query them via cudaDeviceGetAttribute instead.
    int clockRate = 0;
    int memoryClockRate = 0;
    CUDA_CHECK(cudaDeviceGetAttribute(&clockRate, cudaDevAttrClockRate, 0));
    CUDA_CHECK(cudaDeviceGetAttribute(&memoryClockRate, cudaDevAttrMemoryClockRate, 0));

    printf("Part 1: your actual GPU, queried directly\n");
    printf("  name:                 %s\n", prop.name);
    printf("  compute capability:   %d.%d\n", prop.major, prop.minor);
    printf("  SM count:             %d\n", prop.multiProcessorCount);

    int cps = cores_per_sm(prop.major, prop.minor);
    if (cps > 0) {
        printf("  cores per SM:         %d (architecture-specific, not derived from cc alone)\n", cps);
        printf("  total CUDA cores:     %d\n", prop.multiProcessorCount * cps);
    } else {
        printf("  cores per SM:         unknown for this architecture -- not guessing\n");
    }
    printf("\n");

    printf("Part 2: clock and memory\n");
    printf("  GPU clock:            %.2f GHz\n", clockRate / 1.0e6);
    printf("  memory clock:         %.2f GHz\n", memoryClockRate / 1.0e6);
    printf("  memory bus width:     %d bits\n", prop.memoryBusWidth);
    double theoretical_bw_gbps = 2.0 * memoryClockRate * (prop.memoryBusWidth / 8) / 1.0e6;
    printf("  theoretical peak bandwidth: %.1f GB/s (2 x memClock x busWidth/8;\n", theoretical_bw_gbps);
    printf("                               real achieved bandwidth is typically lower)\n");
    printf("  total global memory:  %.1f GB\n\n", prop.totalGlobalMem / (1024.0 * 1024.0 * 1024.0));

    printf("Part 3: per-SM limits (why occupancy numbers are what they are)\n");
    printf("  warp size:                    %d\n", prop.warpSize);
    printf("  max threads per SM:           %d\n", prop.maxThreadsPerMultiProcessor);
    printf("  max threads per block:        %d\n", prop.maxThreadsPerBlock);
    printf("  shared memory per block:      %zu bytes (%.1f KB)\n",
           prop.sharedMemPerBlock, prop.sharedMemPerBlock / 1024.0);
    printf("  L2 cache size:                %.1f MB\n\n", prop.l2CacheSize / (1024.0 * 1024.0));

    printf("Part 4: a typical desktop CPU, for comparison (reference figures, not queried)\n");
    printf("  these are illustrative numbers for a common 8-core desktop CPU circa\n");
    printf("  this course's writing -- not measured on your actual CPU. the point is\n");
    printf("  the shape of the comparison, not precision to the last digit.\n");
    printf("  cores:                 ~8 (a handful, each one powerful)\n");
    printf("  clock:                 ~3.5-5.0 GHz boost\n");
    printf("  cache:                 tens of MB of L3, shared across all cores\n");
    printf("  design goal:           finish ONE task as fast as possible (latency)\n\n");

    printf("Part 5: the GPU's design goal, stated the same way\n");
    printf("  cores:                 thousands, each one simple\n");
    printf("  clock:                 typically lower than a CPU's boost clock\n");
    printf("  cache:                 small per-SM, shared memory instead is explicit\n");
    printf("  design goal:           finish THOUSANDS of tasks per second (throughput)\n\n");

    // --- Verification: structural facts that must hold, not opinions ---
    bool warp_size_ok = (prop.warpSize == 32);
    bool sm_count_ok = (prop.multiProcessorCount > 0);
    printf("Verification: warp_size_is_32 = %s\n", warp_size_ok ? "PASS" : "FAIL");
    printf("Verification: sm_count_positive = %s\n", sm_count_ok ? "PASS" : "FAIL");

    bool ampere_86_threads_ok = true;
    if (prop.major == 8 && prop.minor == 6) {
        ampere_86_threads_ok = (prop.maxThreadsPerMultiProcessor == 1536);
        printf("Verification: sm_86_max_threads_per_sm_is_1536 = %s\n",
               ampere_86_threads_ok ? "PASS" : "FAIL");
    } else {
        printf("  (skipping the 1536-threads-per-SM check -- this GPU isn't compute capability 8.6)\n");
    }

    bool all_pass = warp_size_ok && sm_count_ok && ampere_86_threads_ok;
    printf("\nVerification: all_checks = %s\n", all_pass ? "PASS" : "FAIL");
    return all_pass ? 0 : 1;
}
