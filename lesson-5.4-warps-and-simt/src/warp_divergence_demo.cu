// warp_divergence_demo.cu
// Lesson 5.4 -- warps and SIMT: the 32-thread unit that actually
// executes. Every kernel since lesson 5.1 has been described as
// "threads running independently." That was a useful simplification.
// This lesson replaces it with what's actually true underneath, and
// proves it with a real timing difference, not just an assertion.
#include <cstdio>
#include <cmath>
#include <vector>
#include <chrono>
#include <algorithm>
#include "../common/cuda_check.cuh"

constexpr int kN = 1 << 20;      // ~1M elements
constexpr int kBlockSize = 256;
constexpr int kIterations = 200;

// --- every thread in every warp takes the identical path ---
__global__ void non_divergent_work(float* out, int n, int iterations) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= n) return;
    float val = (float)i;
    for (int k = 0; k < iterations; ++k) {
        val = val * 1.0001f + 0.0001f;
    }
    out[i] = val;
}

// --- even and odd threads within the SAME warp take different paths.
// Both branches do the same NUMBER of iterations -- this isn't about
// one thread doing more real work than another. It's isolating the
// cost of the branch itself. ---
__global__ void divergent_work(float* out, int n, int iterations) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= n) return;
    float val = (float)i;
    if (threadIdx.x % 2 == 0) {
        for (int k = 0; k < iterations; ++k) {
            val = val * 1.0001f + 0.0001f;
        }
    } else {
        for (int k = 0; k < iterations; ++k) {
            val = val * 1.0002f + 0.0002f;
        }
    }
    out[i] = val;
}

static double median_ms(std::vector<double>& times) {
    std::sort(times.begin(), times.end());
    return times[times.size() / 2];
}

int main() {
    // --- Part 1: confirm warp size on this actual hardware ---
    cudaDeviceProp prop;
    CUDA_CHECK(cudaGetDeviceProperties(&prop, 0));
    printf("Part 1: the warp, on your actual GPU\n");
    printf("  warpSize = %d\n", prop.warpSize);
    bool warp_32 = (prop.warpSize == 32);
    printf("  Verification: warp_size_is_32 = %s\n\n", warp_32 ? "PASS" : "FAIL");
    printf("  32 threads, one shared instruction stream. every thread in a\n");
    printf("  warp executes the SAME instruction at the SAME moment -- this\n");
    printf("  is what SIMT actually means, and it's true whether or not your\n");
    printf("  kernel's code ever mentions a warp explicitly.\n\n");

    int* d_dummy = nullptr; (void)d_dummy;
    float* d_a = nullptr;
    float* d_b = nullptr;
    CUDA_CHECK(cudaMalloc(&d_a, kN * sizeof(float)));
    CUDA_CHECK(cudaMalloc(&d_b, kN * sizeof(float)));

    int grid = (kN + kBlockSize - 1) / kBlockSize;

    // --- Part 2: time both versions, median of several runs ---
    printf("Part 2: same total iterations per thread, one version branches\n");
    std::vector<double> non_div_times, div_times;

    for (int t = 0; t < 10; ++t) {
        cudaEvent_t start, stop;
        CUDA_CHECK(cudaEventCreate(&start));
        CUDA_CHECK(cudaEventCreate(&stop));
        CUDA_CHECK(cudaEventRecord(start));
        non_divergent_work<<<grid, kBlockSize>>>(d_a, kN, kIterations);
        CUDA_CHECK(cudaGetLastError());
        CUDA_CHECK(cudaEventRecord(stop));
        CUDA_CHECK(cudaEventSynchronize(stop));
        float ms = 0.0f;
        CUDA_CHECK(cudaEventElapsedTime(&ms, start, stop));
        non_div_times.push_back(ms);
        CUDA_CHECK(cudaEventDestroy(start));
        CUDA_CHECK(cudaEventDestroy(stop));
    }

    for (int t = 0; t < 10; ++t) {
        cudaEvent_t start, stop;
        CUDA_CHECK(cudaEventCreate(&start));
        CUDA_CHECK(cudaEventCreate(&stop));
        CUDA_CHECK(cudaEventRecord(start));
        divergent_work<<<grid, kBlockSize>>>(d_b, kN, kIterations);
        CUDA_CHECK(cudaGetLastError());
        CUDA_CHECK(cudaEventRecord(stop));
        CUDA_CHECK(cudaEventSynchronize(stop));
        float ms = 0.0f;
        CUDA_CHECK(cudaEventElapsedTime(&ms, start, stop));
        div_times.push_back(ms);
        CUDA_CHECK(cudaEventDestroy(start));
        CUDA_CHECK(cudaEventDestroy(stop));
    }

    double non_div_ms = median_ms(non_div_times);
    double div_ms = median_ms(div_times);

    printf("  non-divergent median: %.3f ms\n", non_div_ms);
    printf("  divergent median:     %.3f ms\n", div_ms);
    printf("  divergent / non-divergent ratio: %.2fx\n\n", div_ms / non_div_ms);

    // --- Part 3: correctness, independent of the timing question ---
    std::vector<float> h_a(kN), h_b(kN);
    CUDA_CHECK(cudaMemcpy(h_a.data(), d_a, kN * sizeof(float), cudaMemcpyDeviceToHost));
    CUDA_CHECK(cudaMemcpy(h_b.data(), d_b, kN * sizeof(float), cudaMemcpyDeviceToHost));

    auto cpu_reference = [](float start, float mul, float add, int iters) {
        float v = start;
        for (int k = 0; k < iters; ++k) v = v * mul + add;
        return v;
    };

    float expected_even = cpu_reference(100.0f, 1.0001f, 0.0001f, kIterations);
    float expected_odd = cpu_reference(101.0f, 1.0002f, 0.0002f, kIterations);
    bool correct = (std::fabs(h_b[100] - expected_even) < 1e-2f) &&
                    (std::fabs(h_b[101] - expected_odd) < 1e-2f);

    printf("Part 3: correctness -- divergence changes timing, never the answer\n");
    printf("  even thread (100): got %.4f, expected %.4f\n", h_b[100], expected_even);
    printf("  odd thread (101):  got %.4f, expected %.4f\n", h_b[101], expected_odd);
    printf("  Verification: divergent_kernel_still_correct = %s\n\n", correct ? "PASS" : "FAIL");

    // --- Part 4: the actual point ---
    bool divergence_cost_visible = (div_ms > non_div_ms * 1.2); // meaningfully slower, not just noise
    printf("Part 4: what the timing difference actually proves\n");
    printf("  Verification: divergence_measurably_slower = %s\n", divergence_cost_visible ? "PASS" : "FAIL");
    printf("  each thread still does exactly %d iterations of real work either\n", kIterations);
    printf("  way -- the only difference is whether every thread in a warp took\n");
    printf("  the same branch. when they don't, the warp runs BOTH branches,\n");
    printf("  masking out whichever half isn't active for each one. that serial\n");
    printf("  replay is the entire cost -- not extra math, just extra passes.\n\n");

    printf("Part 5: why block sizes are usually multiples of 32\n");
    printf("  a block size that isn't a multiple of the warp size leaves the\n");
    printf("  last warp partially empty -- some lanes launched with nothing\n");
    printf("  valid to do, still costing a full warp's worth of scheduling.\n");
    printf("  this is a preview of occupancy tuning in module 10.\n");

    bool all_pass = warp_32 && correct && divergence_cost_visible;
    printf("\nVerification: all_checks = %s\n", all_pass ? "PASS" : "FAIL");

    CUDA_CHECK(cudaFree(d_a));
    CUDA_CHECK(cudaFree(d_b));
    return all_pass ? 0 : 1;
}
