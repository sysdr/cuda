// arithmetic_intensity_demo.cu
// Lesson 3.5 -- arithmetic intensity, the number that predicts whether
// a GPU will help at all, before you write a single line of kernel
// code. Module 3's closer, and the last lesson before Module 5 finally
// launches a real kernel.
//
// This lesson queries your actual GPU (same cudaGetDeviceProperties
// pattern as lesson 3.1) to compute a real ridge point for YOUR
// hardware, then classifies several operations -- including lesson
// 2.2's matmul -- against it. No kernel launch here either; this is
// the analysis you do before writing the kernel, not the kernel itself.
#include <cstdio>
#include "../common/cuda_check.cuh"

// Same architecture-specific lookup as lesson 3.1 -- redefined locally
// since every lesson's zip in this course is self-contained.
int cores_per_sm(int major, int minor) {
    if (major == 8 && minor == 6) return 128; // Ampere consumer -- this course's target
    if (major == 8 && minor == 9) return 128; // Ada consumer
    if (major == 8 && minor == 0) return 64;  // Ampere datacenter
    if (major == 7 && minor == 5) return 64;  // Turing
    if (major == 7 && minor == 0) return 64;  // Volta
    if (major == 6) return 128;               // Pascal, most consumer variants
    return -1;
}

int main() {
    // --- Part 1: query real peak FLOPS and real peak bandwidth for
    // THIS machine -- same device query as lesson 3.1, put to a new use ---
    cudaDeviceProp prop;
    CUDA_CHECK(cudaGetDeviceProperties(&prop, 0));

    int cps = cores_per_sm(prop.major, prop.minor);
    printf("Part 1: your GPU's real peak numbers\n");
    printf("  device: %s (cc %d.%d)\n", prop.name, prop.major, prop.minor);

    double peak_gflops = 0.0;
    if (cps > 0) {
        long long total_cores = (long long)prop.multiProcessorCount * cps;
        double clock_ghz = prop.clockRate / 1.0e6;
        // 2 FLOPs per cycle per core is the standard FMA assumption --
        // one fused multiply-add counts as two floating point operations
        peak_gflops = total_cores * clock_ghz * 2.0;
        printf("  total cores:        %lld\n", total_cores);
        printf("  clock:              %.2f GHz\n", clock_ghz);
        printf("  peak compute:       %.1f GFLOP/s (assumes 2 FLOPs/cycle/core, FMA)\n", peak_gflops);
    } else {
        printf("  cores per SM unknown for this architecture -- cannot compute peak FLOPS\n");
        return 1;
    }

    double peak_bandwidth_gbps = 2.0 * prop.memoryClockRate * (prop.memoryBusWidth / 8) / 1.0e6;
    printf("  peak bandwidth:     %.1f GB/s (theoretical, from clock and bus width)\n\n", peak_bandwidth_gbps);

    // --- Part 2: the ridge point -- the arithmetic intensity where
    // compute and memory cost exactly balance, for THIS card ---
    double ridge_point = peak_gflops / peak_bandwidth_gbps; // FLOP/byte
    printf("Part 2: the ridge point for your specific GPU\n");
    printf("  ridge point = peak compute / peak bandwidth = %.1f / %.1f = %.2f FLOP/byte\n",
           peak_gflops, peak_bandwidth_gbps, ridge_point);
    printf("  below this arithmetic intensity: memory-bound (bandwidth is the limit)\n");
    printf("  above this arithmetic intensity: compute-bound (FLOPS is the limit)\n\n");

    // --- Part 3: arithmetic intensity of real operations from this course ---
    printf("Part 3: arithmetic intensity of operations you've already built\n");

    // vector add: c[i] = a[i] + b[i]. 1 FLOP, 3 memory accesses (2 read + 1 write) x 4 bytes
    double vecadd_flops = 1.0;
    double vecadd_bytes = 3.0 * 4.0;
    double vecadd_ai = vecadd_flops / vecadd_bytes;
    printf("  vector add (lesson 7.1-style):     1 FLOP / 12 bytes = %.4f FLOP/byte\n", vecadd_ai);

    // SAXPY: y[i] = a*x[i] + y[i]. 2 FLOPs (mul, add), 2 read + 1 write x 4 bytes
    double saxpy_flops = 2.0;
    double saxpy_bytes = 3.0 * 4.0;
    double saxpy_ai = saxpy_flops / saxpy_bytes;
    printf("  SAXPY (a*x + y):                    2 FLOP / 12 bytes = %.4f FLOP/byte\n", saxpy_ai);

    // naive matmul at N: 2*N^3 FLOPs (mul+add per term), minimum 3*N^2*4 bytes
    // moved if every input were read exactly once (the theoretical best case)
    auto matmul_ai = [](double n) {
        double flops = 2.0 * n * n * n;
        double bytes = 3.0 * n * n * 4.0;
        return flops / bytes; // simplifies to n / 6
    };

    printf("  naive matmul (lesson 2.2/7.4-style), by size:\n");
    double test_sizes[] = {64, 256, 1024, 4096};
    for (double n : test_sizes) {
        printf("    N=%-6.0f AI = %.2f FLOP/byte\n", n, matmul_ai(n));
    }
    printf("\n");

    // --- Part 4: classify each against the ridge point, and find the
    // crossover N where matmul flips from memory-bound to compute-bound ---
    printf("Part 4: classifying against your ridge point (%.2f FLOP/byte)\n", ridge_point);
    bool vecadd_memory_bound = (vecadd_ai < ridge_point);
    bool saxpy_memory_bound = (saxpy_ai < ridge_point);
    printf("  vector add: AI=%.4f %s ridge point -> %s\n",
           vecadd_ai, vecadd_memory_bound ? "<" : ">=",
           vecadd_memory_bound ? "memory-bound" : "compute-bound");
    printf("  SAXPY:      AI=%.4f %s ridge point -> %s\n",
           saxpy_ai, saxpy_memory_bound ? "<" : ">=",
           saxpy_memory_bound ? "memory-bound" : "compute-bound");

    double crossover_n = 6.0 * ridge_point; // solve n/6 = ridge_point
    printf("  naive matmul crosses from memory-bound to compute-bound at N ~= %.0f\n", crossover_n);
    bool matmul_small_memory_bound = (matmul_ai(64) < ridge_point);
    bool matmul_large_compute_bound = (matmul_ai(4096) > ridge_point);
    printf("  matmul at N=64:   AI=%.2f -> %s (small matrices: memory-bound)\n",
           matmul_ai(64), matmul_small_memory_bound ? "memory-bound" : "compute-bound");
    printf("  matmul at N=4096: AI=%.2f -> %s (large matrices: compute-bound)\n\n",
           matmul_ai(4096), matmul_large_compute_bound ? "memory-bound" : "compute-bound");

    printf("Part 5: what this predicts, before any kernel exists\n");
    printf("  vector add and SAXPY are memory-bound at ANY size -- their arithmetic\n");
    printf("  intensity is fixed by the operation itself and never grows. matmul's\n");
    printf("  arithmetic intensity grows with N (this is exactly what lesson 2.2\n");
    printf("  predicted: O(N^3) flops over O(N^2) bytes), which is why tiling in\n");
    printf("  lesson 7.5 pays off the way it does -- there's real compute to hide\n");
    printf("  memory latency behind, once N is large enough. this is also exactly\n");
    printf("  what lesson 11.4's roofline model plots directly.\n");

    // --- Verification ---
    bool ai_formulas_correct = (vecadd_ai > 0.08 && vecadd_ai < 0.09) &&
                                (saxpy_ai > 0.16 && saxpy_ai < 0.17);
    bool classification_correct = vecadd_memory_bound && saxpy_memory_bound &&
                                   matmul_small_memory_bound && matmul_large_compute_bound;

    printf("Verification: ai_formulas_correct = %s\n", ai_formulas_correct ? "PASS" : "FAIL");
    printf("Verification: classification_matches_expected_pattern = %s\n",
           classification_correct ? "PASS" : "FAIL");

    bool all_pass = ai_formulas_correct && classification_correct;
    printf("\nVerification: all_checks = %s\n", all_pass ? "PASS" : "FAIL");
    return all_pass ? 0 : 1;
}
