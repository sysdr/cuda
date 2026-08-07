// amdahls_law_demo.cu
// Lesson 3.4 -- Amdahl's law and parallelism limits. A program's speedup
// from parallelizing is capped by the fraction that CAN'T be
// parallelized, no matter how many threads you throw at the rest. This
// lesson builds a real two-part workload -- one piece that must run
// sequentially, one piece that splits cleanly across threads -- and
// measures the actual speedup curve against what the formula predicts.
//
// No kernel launch -- Module 3 is still Phase 1. Uses std::thread, same
// as lessons 3.2 and 3.3.
#include <cstdio>
#include <cstdlib>
#include <cmath>
#include <thread>
#include <vector>
#include <chrono>
#include "../common/cuda_check.cuh"

// --- the serial piece: each step depends on the previous one, so this
// cannot be split across threads no matter how many you have ---
double serial_work(long iterations) {
    double x = 1.0000001;
    for (long i = 0; i < iterations; ++i) {
        x = x * 1.0000001 + 0.0000001; // genuinely sequential recurrence
    }
    return x;
}

// --- the parallel piece: independent work, splits cleanly ---
double parallel_chunk(const std::vector<float>& data, long start, long end) {
    double sum = 0.0;
    for (long i = start; i < end; ++i) {
        sum += std::sin((double)data[i]) * std::cos((double)data[i]);
    }
    return sum;
}

double parallel_work(const std::vector<float>& data, int num_threads) {
    long n = (long)data.size();
    long chunk = n / num_threads;
    std::vector<std::thread> threads;
    std::vector<double> partials(num_threads, 0.0);

    for (int t = 0; t < num_threads; ++t) {
        long start = t * chunk;
        long end = (t == num_threads - 1) ? n : start + chunk;
        threads.emplace_back([&, t, start, end]() {
            partials[t] = parallel_chunk(data, start, end);
        });
    }
    for (auto& th : threads) th.join();

    double total = 0.0;
    for (double p : partials) total += p;
    return total;
}

double amdahl_speedup(double parallel_fraction, int n) {
    return 1.0 / ((1.0 - parallel_fraction) + parallel_fraction / n);
}

int main() {
    constexpr long kSerialIterations = 60000000L;
    constexpr long kParallelElements = 40000000L;

    std::vector<float> data(kParallelElements);
    srand(42);
    for (long i = 0; i < kParallelElements; ++i) data[i] = (rand() % 1000) / 1000.0f;

    // --- measure the serial and parallel pieces separately, at N=1,
    // to find out the REAL parallel fraction rather than assuming one ---
    printf("Part 1: measuring the serial and parallel pieces separately\n");
    auto s0 = std::chrono::high_resolution_clock::now();
    double serial_result = serial_work(kSerialIterations);
    auto s1 = std::chrono::high_resolution_clock::now();
    double serial_ms = std::chrono::duration<double, std::milli>(s1 - s0).count();

    auto p0 = std::chrono::high_resolution_clock::now();
    double parallel_result = parallel_work(data, 1);
    auto p1 = std::chrono::high_resolution_clock::now();
    double parallel_ms_at_1 = std::chrono::duration<double, std::milli>(p1 - p0).count();

    double baseline_total_ms = serial_ms + parallel_ms_at_1;
    double measured_parallel_fraction = parallel_ms_at_1 / baseline_total_ms;

    printf("  serial piece alone:    %.1f ms (%.1f%% of baseline)\n",
           serial_ms, 100.0 * serial_ms / baseline_total_ms);
    printf("  parallel piece alone:  %.1f ms (%.1f%% of baseline)\n",
           parallel_ms_at_1, 100.0 * measured_parallel_fraction);
    printf("  baseline total (N=1):  %.1f ms\n", baseline_total_ms);
    printf("  measured parallel fraction P = %.3f\n\n", measured_parallel_fraction);
    (void)serial_result; (void)parallel_result;

    // --- now measure actual combined speedup at N=2,4,8 and compare
    // against what Amdahl's formula predicts for the measured P ---
    printf("Part 2: measured speedup vs Amdahl's predicted speedup\n");
    printf("%-6s %-16s %-20s %-10s\n", "N", "measured (ms)", "empirical speedup", "predicted");

    int thread_counts[] = {2, 4, 8};
    double empirical_speedups[3];
    double predicted_speedups[3];
    bool all_within_bound = true;

    for (int idx = 0; idx < 3; ++idx) {
        int n = thread_counts[idx];
        auto t0 = std::chrono::high_resolution_clock::now();
        double sr = serial_work(kSerialIterations);   // still fully sequential
        double pr = parallel_work(data, n);           // split across n threads
        auto t1 = std::chrono::high_resolution_clock::now();
        double total_ms = std::chrono::duration<double, std::milli>(t1 - t0).count();
        (void)sr; (void)pr;

        double empirical = baseline_total_ms / total_ms;
        double predicted = amdahl_speedup(measured_parallel_fraction, n);
        empirical_speedups[idx] = empirical;
        predicted_speedups[idx] = predicted;

        printf("%-6d %-16.1f %-20.2f %-10.2f\n", n, total_ms, empirical, predicted);

        // real measured speedup should not exceed the theoretical prediction
        // by more than a small noise tolerance -- Amdahl's formula ignores
        // real overhead (thread creation cost from lesson 3.2, cache
        // effects, etc.), so reality should sit at or below the prediction,
        // not above it
        if (empirical > predicted * 1.15) all_within_bound = false;
    }
    printf("\n");

    double ceiling = 1.0 / (1.0 - measured_parallel_fraction);
    printf("Part 3: the ceiling -- what infinite threads could never beat\n");
    printf("  theoretical max speedup as N -> infinity: %.2fx\n", ceiling);
    printf("  best measured speedup here (N=8): %.2fx\n", empirical_speedups[2]);
    printf("  even with 8 threads, we're at %.0f%% of a ceiling we'll never fully reach\n\n",
           100.0 * empirical_speedups[2] / ceiling);

    bool speedup_increasing = (empirical_speedups[0] < empirical_speedups[1]) &&
                               (empirical_speedups[1] < empirical_speedups[2]);
    bool below_ceiling = empirical_speedups[2] < ceiling;

    printf("Verification: empirical_speedup_within_predicted_bound = %s\n",
           all_within_bound ? "PASS" : "FAIL");
    printf("Verification: speedup_increases_with_thread_count = %s\n",
           speedup_increasing ? "PASS" : "FAIL");
    printf("Verification: speedup_stays_below_theoretical_ceiling = %s\n\n",
           below_ceiling ? "PASS" : "FAIL");

    printf("Part 4: the gap between measured and predicted has a name you already know\n");
    printf("  the small gap between the empirical and predicted columns above is not\n");
    printf("  noise to be explained away -- some of it is exactly the thread creation\n");
    printf("  cost lesson 3.2 measured directly. Amdahl's formula assumes splitting\n");
    printf("  work across threads is free. lesson 3.2 proved it isn't.\n");
    printf("  this is also why a GPU kernel's real measured speedup in Module 7 never\n");
    printf("  hits a naive 'thousands of threads = thousands of times faster' number --\n");
    printf("  memory transfer, kernel launch overhead, and any serial setup all count\n");
    printf("  against the parallel fraction, exactly the way this lesson's serial_work\n");
    printf("  does here.\n");

    bool all_pass = all_within_bound && speedup_increasing && below_ceiling;
    printf("\nVerification: all_checks = %s\n", all_pass ? "PASS" : "FAIL");
    return all_pass ? 0 : 1;
}
