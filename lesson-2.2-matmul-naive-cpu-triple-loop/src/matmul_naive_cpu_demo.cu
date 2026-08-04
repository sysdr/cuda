// matmul_naive_cpu_demo.cu
// Lesson 2.2 -- matrix multiplication as a naive CPU triple loop. This
// is the same computation lesson 7.4/7.5 later put on a GPU -- today's
// version is deliberately the slow, obvious one, on one CPU core, so
// the O(N^3) growth is something you've actually watched happen before
// a kernel ever tries to hide it from you.
//
// No CUDA calls in this file at all -- same precedent as 1.3 and 2.1.
// This lesson is pure CPU arithmetic and timing.
#include <cstdio>
#include <cstdlib>
#include <cmath>
#include <vector>
#include <chrono>
#include <algorithm>

// --- Part 1: the naive triple loop, C = A * B for N x N matrices ---
void matmul_naive(const std::vector<float>& A, const std::vector<float>& B,
                   std::vector<float>& C, int n) {
    for (int i = 0; i < n; ++i) {
        for (int j = 0; j < n; ++j) {
            float sum = 0.0f;
            for (int k = 0; k < n; ++k) {
                sum += A[i * n + k] * B[k * n + j];
            }
            C[i * n + j] = sum;
        }
    }
}

// --- Part 3: the same computation, written to make the lesson 2.1
// connection explicit -- C[i][j] really is dot_n(row_i, col_j) ---
float dot_n(const std::vector<float>& a, const std::vector<float>& b) {
    float sum = 0.0f;
    for (size_t i = 0; i < a.size(); ++i) sum += a[i] * b[i];
    return sum;
}

void matmul_via_dot_n(const std::vector<float>& A, const std::vector<float>& B,
                       std::vector<float>& C, int n) {
    for (int i = 0; i < n; ++i) {
        std::vector<float> row(n);
        for (int k = 0; k < n; ++k) row[k] = A[i * n + k];

        for (int j = 0; j < n; ++j) {
            std::vector<float> col(n);
            for (int k = 0; k < n; ++k) col[k] = B[k * n + j];
            C[i * n + j] = dot_n(row, col);
        }
    }
}

static double median_ms(std::vector<double>& times) {
    std::sort(times.begin(), times.end());
    return times[times.size() / 2];
}

int main(int argc, char** argv) {
    int n = argc > 1 ? atoi(argv[1]) : 256;

    // --- Part 2: a small, hand-checkable example first ---
    printf("Part 2: a 2x2 example you can verify by hand\n");
    std::vector<float> smallA = {1, 2, 3, 4};
    std::vector<float> smallB = {5, 6, 7, 8};
    std::vector<float> smallC(4);
    matmul_naive(smallA, smallB, smallC, 2);
    printf("  A = [[1,2],[3,4]]   B = [[5,6],[7,8]]\n");
    printf("  C = [[%.0f,%.0f],[%.0f,%.0f]]\n", smallC[0], smallC[1], smallC[2], smallC[3]);
    printf("  by hand: C[0][0] = 1*5+2*7 = 19, C[0][1] = 1*6+2*8 = 22\n");
    printf("           C[1][0] = 3*5+4*7 = 43, C[1][1] = 3*6+4*8 = 50\n");
    bool small_ok = (smallC[0] == 19 && smallC[1] == 22 && smallC[2] == 43 && smallC[3] == 50);
    printf("  Verification: small_example_matches_hand_calc = %s\n\n", small_ok ? "PASS" : "FAIL");

    // --- Part 3: prove C[i][j] really is dot_n(row_i, col_j) ---
    printf("Part 3: the same 2x2 example, computed explicitly via dot_n\n");
    std::vector<float> viaC(4);
    matmul_via_dot_n(smallA, smallB, viaC, 2);
    bool matches_naive = true;
    for (int i = 0; i < 4; ++i) {
        if (std::fabs(viaC[i] - smallC[i]) > 1e-5f) matches_naive = false;
    }
    printf("  matmul_via_dot_n result: [[%.0f,%.0f],[%.0f,%.0f]]\n",
           viaC[0], viaC[1], viaC[2], viaC[3]);
    printf("  Verification: dot_n_version_matches_naive = %s\n\n",
           matches_naive ? "PASS" : "FAIL");

    // --- Part 4: scale up and watch O(N^3) cost real time ---
    printf("Part 4: timing the naive loop at N=%d (%d trials)\n", n, 5);
    std::vector<float> A(n * n), B(n * n), C(n * n);
    srand(42);
    for (int i = 0; i < n * n; ++i) {
        A[i] = (rand() % 1000) / 1000.0f;
        B[i] = (rand() % 1000) / 1000.0f;
    }

    std::vector<double> times;
    for (int trial = 0; trial < 5; ++trial) {
        auto t0 = std::chrono::high_resolution_clock::now();
        matmul_naive(A, B, C, n);
        auto t1 = std::chrono::high_resolution_clock::now();
        times.push_back(std::chrono::duration<double, std::milli>(t1 - t0).count());
    }
    double ms = median_ms(times);
    long long total_multiply_adds = (long long)n * n * n;
    double gflops = (2.0 * total_multiply_adds) / (ms / 1000.0) / 1e9;

    printf("  median time: %.2f ms\n", ms);
    printf("  total multiply-adds: %lld (that's N^3)\n", total_multiply_adds);
    printf("  approx throughput: %.2f GFLOP/s, one CPU core, no vectorization assumed\n\n", gflops);

    printf("Part 5: what this number means going forward\n");
    printf("  this loop reads O(N^2) bytes of input but performs O(N^3)\n");
    printf("  multiply-adds -- more math per byte moved as N grows. that ratio\n");
    printf("  has a name, arithmetic intensity, and it's the whole subject of\n");
    printf("  lesson 3.5. lessons 7.4 and 7.5 put this exact computation on a\n");
    printf("  GPU -- same triple loop in spirit, thousands of threads instead\n");
    printf("  of one CPU core working through it in sequence.\n");

    bool all_pass = small_ok && matches_naive;
    printf("\nVerification: all_checks = %s\n", all_pass ? "PASS" : "FAIL");
    return all_pass ? 0 : 1;
}
