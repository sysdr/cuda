// race_conditions_demo.cu
// Lesson 3.3 -- race conditions and synchronization. Picks up directly
// from lesson 3.2's atomic counter and asks the obvious next question:
// what happens the moment the atomicity is removed?
//
// One section of this file deliberately reproduces a real data race on
// a plain (non-atomic) int shared across threads. This is undefined
// behavior by the C++ standard -- in practice, on every real system,
// it reliably produces lost updates rather than a crash, which is
// exactly what makes races insidious: the program doesn't complain,
// it just quietly computes the wrong answer. See NOTES.md.
//
// Still no kernel launch -- Module 3 is Phase 1 territory. This lesson
// explains, retroactively, why lesson 7.5's matmul_tiled_kernel needed
// two calls to __syncthreads() per tile iteration.
#include <cstdio>
#include <thread>
#include <atomic>
#include <mutex>
#include <vector>
#include <chrono>
#include <algorithm>
#include "../common/cuda_check.cuh"

constexpr int kNumThreads = 8;
constexpr int kIncrementsPerThread = 500000;
constexpr int kExpected = kNumThreads * kIncrementsPerThread;

// --- Part 1: the race. A plain int, no synchronization at all. ---
int race_counter = 0;

void racy_worker() {
    for (int i = 0; i < kIncrementsPerThread; ++i) {
        race_counter++; // read, add one, write back -- not one atomic step
    }
}

// --- Part 2: fixed with a mutex ---
int mutex_counter = 0;
std::mutex counter_mutex;

void mutex_worker() {
    for (int i = 0; i < kIncrementsPerThread; ++i) {
        std::lock_guard<std::mutex> lock(counter_mutex);
        mutex_counter++;
    }
}

// --- Part 3: fixed with an atomic ---
std::atomic<int> atomic_counter{0};

void atomic_worker() {
    for (int i = 0; i < kIncrementsPerThread; ++i) {
        atomic_counter.fetch_add(1, std::memory_order_relaxed);
    }
}

static double median_ms(std::vector<double>& times) {
    std::sort(times.begin(), times.end());
    return times[times.size() / 2];
}

int main() {
    printf("Expected final count in every version below: %d\n\n", kExpected);

    // --- Part 1: run the race three times, show it's wrong AND unstable ---
    printf("Part 1: the race -- %d threads, no synchronization, run 3 times\n", kNumThreads);
    bool race_ever_wrong = false;
    int results[3];
    for (int run = 0; run < 3; ++run) {
        race_counter = 0;
        std::vector<std::thread> threads;
        for (int t = 0; t < kNumThreads; ++t) threads.emplace_back(racy_worker);
        for (auto& th : threads) th.join();
        results[run] = race_counter;
        printf("  run %d: final count = %d (missing %d updates)\n",
               run + 1, race_counter, kExpected - race_counter);
        if (race_counter != kExpected) race_ever_wrong = true;
    }
    bool results_unstable = (results[0] != results[1]) || (results[1] != results[2]);
    printf("  Verification: race_condition_reproduced = %s\n", race_ever_wrong ? "PASS" : "FAIL");
    printf("  (PASS here means the bug was successfully demonstrated --\n");
    printf("  this is the one lesson in this course where PASS proves a\n");
    printf("  problem exists rather than proving correctness. see the lesson text.)\n");
    printf("  Verification: results_differ_across_runs = %s\n\n", results_unstable ? "PASS" : "FAIL");

    // --- Part 2: mutex fix ---
    printf("Part 2: fixed with std::mutex\n");
    {
        std::vector<std::thread> threads;
        for (int t = 0; t < kNumThreads; ++t) threads.emplace_back(mutex_worker);
        for (auto& th : threads) th.join();
    }
    printf("  final count = %d\n", mutex_counter);
    bool mutex_ok = (mutex_counter == kExpected);
    printf("  Verification: mutex_counter_correct = %s\n\n", mutex_ok ? "PASS" : "FAIL");

    // --- Part 3: atomic fix, plus a timing comparison against the mutex ---
    printf("Part 3: fixed with std::atomic, and how their costs compare\n");
    std::vector<double> mutex_times, atomic_times;

    for (int trial = 0; trial < 5; ++trial) {
        mutex_counter = 0;
        auto t0 = std::chrono::high_resolution_clock::now();
        std::vector<std::thread> threads;
        for (int t = 0; t < kNumThreads; ++t) threads.emplace_back(mutex_worker);
        for (auto& th : threads) th.join();
        auto t1 = std::chrono::high_resolution_clock::now();
        mutex_times.push_back(std::chrono::duration<double, std::milli>(t1 - t0).count());
    }

    for (int trial = 0; trial < 5; ++trial) {
        atomic_counter.store(0);
        auto t0 = std::chrono::high_resolution_clock::now();
        std::vector<std::thread> threads;
        for (int t = 0; t < kNumThreads; ++t) threads.emplace_back(atomic_worker);
        for (auto& th : threads) th.join();
        auto t1 = std::chrono::high_resolution_clock::now();
        atomic_times.push_back(std::chrono::duration<double, std::milli>(t1 - t0).count());
    }

    double mutex_ms = median_ms(mutex_times);
    double atomic_ms = median_ms(atomic_times);
    bool atomic_ok = (atomic_counter.load() == kExpected);

    printf("  atomic final count = %d\n", atomic_counter.load());
    printf("  Verification: atomic_counter_correct = %s\n", atomic_ok ? "PASS" : "FAIL");
    printf("  mutex median time:  %.2f ms\n", mutex_ms);
    printf("  atomic median time: %.2f ms\n", atomic_ms);
    printf("  atomic is %.2fx faster here for this simple increment\n\n", mutex_ms / atomic_ms);

    // --- Part 4: the GPU-side names for the same two ideas ---
    printf("Part 4: the same two ideas, on a GPU\n");
    printf("  atomicAdd() on a GPU is the same concept as std::atomic's fetch_add --\n");
    printf("  a hardware-guaranteed, uninterruptible read-modify-write. lesson 7.6's\n");
    printf("  reduction and the histogram kernel in the source pack both use it.\n");
    printf("  __syncthreads() is a different tool for a different problem -- not\n");
    printf("  protecting one shared value, but making every thread in a block wait\n");
    printf("  at the same point before any of them proceed. lesson 7.5's tiled\n");
    printf("  matmul kernel called it twice per tile iteration: once after loading\n");
    printf("  shared memory, so no thread reads a tile before every thread finished\n");
    printf("  writing it, and once after computing, so no thread overwrites the tile\n");
    printf("  for the next iteration while a slower thread is still reading it.\n");

    bool all_pass = race_ever_wrong && mutex_ok && atomic_ok;
    printf("\nVerification: all_checks = %s\n", all_pass ? "PASS" : "FAIL");
    return all_pass ? 0 : 1;
}
