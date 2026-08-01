// aos_vs_soa_demo.cu
// Lesson 1.4 -- array of structs vs struct of arrays. Same data, two
// layouts, and a measurable difference in how fast you can touch one
// field across every element -- which is exactly the access pattern a
// GPU kernel uses when N threads each read their own element's x field.
//
// The benchmark here runs entirely on the CPU, on purpose. This is
// still Module 1 -- no kernel launch yet. The point being made is
// about memory layout and cache behavior, which is real and measurable
// without a GPU at all. The same principle applies with a much larger
// effect once threads and warps enter the picture in Module 6 and 7.
#include <cstdio>
#include <cstdlib>
#include <cmath>
#include <vector>
#include <chrono>
#include <algorithm>
#include "../common/cuda_check.cuh"

constexpr int kNumParticles = 2000000;
constexpr int kNumSteps = 50;
constexpr float kDt = 0.01f;

// --- Part 1: array of structs. One struct per particle, 7 floats each. ---
// All 7 fields are the same type, so unlike lesson 1.3's example there is
// no padding to worry about here -- sizeof(Particle) is exactly 28 bytes.
struct Particle {
    float x, y, z;
    float vx, vy, vz;
    float mass;
};

// --- Part 2: struct of arrays. Seven separate contiguous arrays instead
// of one array of 7-field structs. ---
struct ParticlesSoA {
    std::vector<float> x, y, z;
    std::vector<float> vx, vy, vz;
    std::vector<float> mass;
    explicit ParticlesSoA(size_t n) : x(n), y(n), z(n), vx(n), vy(n), vz(n), mass(n) {}
};

static double median_ms(std::vector<double>& times) {
    std::sort(times.begin(), times.end());
    std::vector<double> trimmed(times.begin() + 3, times.end());
    return trimmed[trimmed.size() / 2];
}

int main() {
    size_t free_bytes = 0, total_bytes = 0;
    CUDA_CHECK(cudaMemGetInfo(&free_bytes, &total_bytes));
    printf("GPU free memory: %.1f MB / %.1f MB total\n",
           free_bytes / (1024.0 * 1024.0), total_bytes / (1024.0 * 1024.0));

    size_t aos_bytes = (size_t)kNumParticles * sizeof(Particle);
    size_t soa_bytes = (size_t)kNumParticles * 7 * sizeof(float);
    printf("AoS layout: %.1f MB for %d particles\n", aos_bytes / (1024.0 * 1024.0), kNumParticles);
    printf("SoA layout: %.1f MB for %d particles (same data)\n\n", soa_bytes / (1024.0 * 1024.0), kNumParticles);

    // --- fill both layouts with identical data ---
    std::vector<Particle> aos(kNumParticles);
    ParticlesSoA soa(kNumParticles);
    srand(42);
    for (int i = 0; i < kNumParticles; ++i) {
        float vx = (rand() % 1000) / 1000.0f;
        float vy = (rand() % 1000) / 1000.0f;
        float vz = (rand() % 1000) / 1000.0f;
        aos[i] = {0.0f, 0.0f, 0.0f, vx, vy, vz, 1.0f};
        soa.x[i] = 0.0f; soa.y[i] = 0.0f; soa.z[i] = 0.0f;
        soa.vx[i] = vx; soa.vy[i] = vy; soa.vz[i] = vz; soa.mass[i] = 1.0f;
    }

    // --- Part 3: benchmark touching ONLY the x/vx fields, repeatedly ---
    // This mimics what one GPU thread per particle would do if it only
    // needed the x component -- exactly the access pattern that makes
    // struct-of-arrays coalesce well on a GPU and array-of-structs not.
    printf("Part 3: updating x += vx * dt for every particle, %d steps, %d trials\n",
           kNumSteps, 20);

    std::vector<double> aos_times, soa_times;
    for (int trial = 0; trial < 20; ++trial) {
        auto t0 = std::chrono::high_resolution_clock::now();
        for (int step = 0; step < kNumSteps; ++step) {
            for (int i = 0; i < kNumParticles; ++i) {
                aos[i].x += aos[i].vx * kDt;
            }
        }
        auto t1 = std::chrono::high_resolution_clock::now();
        aos_times.push_back(std::chrono::duration<double, std::milli>(t1 - t0).count());
    }

    for (int trial = 0; trial < 20; ++trial) {
        auto t0 = std::chrono::high_resolution_clock::now();
        for (int step = 0; step < kNumSteps; ++step) {
            for (int i = 0; i < kNumParticles; ++i) {
                soa.x[i] += soa.vx[i] * kDt;
            }
        }
        auto t1 = std::chrono::high_resolution_clock::now();
        soa_times.push_back(std::chrono::duration<double, std::milli>(t1 - t0).count());
    }

    double aos_ms = median_ms(aos_times);
    double soa_ms = median_ms(soa_times);
    printf("  AoS median time: %.2f ms\n", aos_ms);
    printf("  SoA median time: %.2f ms\n", soa_ms);
    printf("  SoA speedup: %.2fx\n\n", aos_ms / soa_ms);

    // --- Part 4: verify both layouts computed the identical answer ---
    float max_diff = 0.0f;
    for (int i = 0; i < kNumParticles; ++i) {
        max_diff = fmaxf(max_diff, fabsf(aos[i].x - soa.x[i]));
    }
    printf("Part 4: correctness check -- same math, different layout\n");
    printf("  max_diff between AoS.x and SoA.x = %.8f\n", max_diff);
    printf("  Verification: aos_soa_results_match = %s\n\n", max_diff < 1e-4f ? "PASS" : "FAIL");

    // --- Part 5: what allocating each layout on the device looks like ---
    // No kernel launch here -- that's Module 6/7. This is just the shape
    // of the setup code you'd write, and the one real structural cost of
    // choosing SoA: seven allocations instead of one.
    printf("Part 5: device allocation shape (no kernel launch yet)\n");
    Particle* d_aos = nullptr;
    CUDA_CHECK(cudaMalloc(&d_aos, aos_bytes));
    printf("  AoS: 1 cudaMalloc call for the whole array\n");

    float *d_x, *d_y, *d_z, *d_vx, *d_vy, *d_vz, *d_mass;
    CUDA_CHECK(cudaMalloc(&d_x, kNumParticles * sizeof(float)));
    CUDA_CHECK(cudaMalloc(&d_y, kNumParticles * sizeof(float)));
    CUDA_CHECK(cudaMalloc(&d_z, kNumParticles * sizeof(float)));
    CUDA_CHECK(cudaMalloc(&d_vx, kNumParticles * sizeof(float)));
    CUDA_CHECK(cudaMalloc(&d_vy, kNumParticles * sizeof(float)));
    CUDA_CHECK(cudaMalloc(&d_vz, kNumParticles * sizeof(float)));
    CUDA_CHECK(cudaMalloc(&d_mass, kNumParticles * sizeof(float)));
    printf("  SoA: 7 separate cudaMalloc calls, one per field\n");
    printf("  same total bytes either way, different bookkeeping\n");

    CUDA_CHECK(cudaFree(d_aos));
    CUDA_CHECK(cudaFree(d_x));
    CUDA_CHECK(cudaFree(d_y));
    CUDA_CHECK(cudaFree(d_z));
    CUDA_CHECK(cudaFree(d_vx));
    CUDA_CHECK(cudaFree(d_vy));
    CUDA_CHECK(cudaFree(d_vz));
    CUDA_CHECK(cudaFree(d_mass));

    return max_diff < 1e-4f ? 0 : 1;
}
