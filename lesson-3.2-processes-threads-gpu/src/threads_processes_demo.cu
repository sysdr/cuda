// threads_processes_demo.cu
// Lesson 3.2 -- processes, threads, and what "thread" means on a GPU.
// This lesson demonstrates real OS-level threads on the CPU, measures
// their real creation cost, and uses that measured number as the
// anchor for explaining why a GPU "thread" is a fundamentally
// different, far cheaper thing. Still no kernel launch -- Module 3 is
// Phase 1 territory, same scoping as everything before it. The actual
// GPU thread demonstration is Module 5's job; this lesson sets up why
// it will look so different from what's built here.
#include <cstdio>
#include <thread>
#include <atomic>
#include <vector>
#include <set>
#include <mutex>
#include <chrono>
#include <sstream>
#include "../common/cuda_check.cuh"

constexpr int kNumThreads = 4;
constexpr int kIncrementsPerThread = 100000;

std::atomic<int> shared_counter{0};
std::mutex id_mutex;
std::set<std::string> seen_thread_ids;

void worker(int thread_index) {
    // record this thread's real OS-level identity, proving it's a
    // genuinely separate thread and not just a relabeled call
    {
        std::lock_guard<std::mutex> lock(id_mutex);
        std::ostringstream oss;
        oss << std::this_thread::get_id();
        seen_thread_ids.insert(oss.str());
    }
    for (int i = 0; i < kIncrementsPerThread; ++i) {
        shared_counter.fetch_add(1, std::memory_order_relaxed);
    }
    (void)thread_index;
}

int main() {
    // --- Part 1: real OS threads, a shared atomic counter, and proof
    // that separate threads actually ran ---
    printf("Part 1: %d real OS threads, each incrementing a shared counter %d times\n",
           kNumThreads, kIncrementsPerThread);

    std::vector<std::thread> threads;
    for (int t = 0; t < kNumThreads; ++t) {
        threads.emplace_back(worker, t);
    }
    for (auto& th : threads) {
        th.join();
    }

    int expected = kNumThreads * kIncrementsPerThread;
    printf("  shared_counter final value: %d\n", shared_counter.load());
    printf("  expected: %d\n", expected);
    bool counter_ok = (shared_counter.load() == expected);
    printf("  Verification: atomic_counter_correct = %s\n", counter_ok ? "PASS" : "FAIL");

    printf("  distinct OS thread IDs observed: %zu (expected %d)\n",
           seen_thread_ids.size(), kNumThreads);
    bool ids_ok = (seen_thread_ids.size() == (size_t)kNumThreads);
    printf("  Verification: distinct_thread_ids_observed = %s\n\n", ids_ok ? "PASS" : "FAIL");

    // --- Part 2: what does creating an OS thread actually cost? ---
    printf("Part 2: measuring real OS thread creation + join cost\n");
    constexpr int kTrialThreads = 1000;
    std::vector<double> trial_times;

    for (int trial = 0; trial < 5; ++trial) {
        auto t0 = std::chrono::high_resolution_clock::now();
        {
            std::vector<std::thread> spawn;
            spawn.reserve(kTrialThreads);
            std::atomic<int> dummy{0};
            for (int i = 0; i < kTrialThreads; ++i) {
                spawn.emplace_back([&dummy]() {
                    dummy.fetch_add(1, std::memory_order_relaxed);
                });
            }
            for (auto& th : spawn) th.join();
        }
        auto t1 = std::chrono::high_resolution_clock::now();
        trial_times.push_back(std::chrono::duration<double, std::micro>(t1 - t0).count());
    }
    std::sort(trial_times.begin(), trial_times.end());
    double median_us = trial_times[trial_times.size() / 2];
    double per_thread_us = median_us / kTrialThreads;

    printf("  spawned and joined %d threads, median total time: %.1f us\n", kTrialThreads, median_us);
    printf("  average cost per thread: %.2f us\n\n", per_thread_us);

    // --- Part 3: the contrast, stated with the measured number in hand ---
    printf("Part 3: why this number matters for what comes next\n");
    printf("  every one of those %d threads above involved the operating system:\n", kTrialThreads);
    printf("  a stack allocation, a scheduler registration, real kernel-level\n");
    printf("  bookkeeping. that's why it costs microseconds per thread, not\n");
    printf("  nanoseconds -- spawning a million OS threads this way would take\n");
    printf("  seconds, and nobody does that on a CPU for good reason.\n");
    printf("  a GPU kernel launched in Module 5 will routinely start a million\n");
    printf("  threads in one call. that only works because a GPU thread is not\n");
    printf("  an OS thread -- no separate stack allocation, no scheduler\n");
    printf("  negotiation, no kernel-level bookkeeping per thread. what a GPU\n");
    printf("  thread actually is gets built in Module 5, on top of this contrast.\n");

    bool all_pass = counter_ok && ids_ok;
    printf("\nVerification: all_checks = %s\n", all_pass ? "PASS" : "FAIL");
    return all_pass ? 0 : 1;
}
