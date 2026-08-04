// layout_transpose_stride_demo.cu
// Lesson 2.3 -- row-major vs column-major storage, transpose, and
// stride. This is the direct payoff of lesson 2.2's closing exercise:
// transposing B before multiplying, measured for real.
//
// No CUDA calls in this file -- same precedent as 1.3, 2.1, and 2.2.
// Pure CPU layout and timing.
#include <cstdio>
#include <cstdlib>
#include <cmath>
#include <vector>
#include <chrono>
#include <algorithm>

// --- Part 1 & 2: row-major and column-major indexing for the same
// logical matrix ---
// Row-major: elements of a row sit next to each other in memory.
// Column-major: elements of a column sit next to each other instead.
int row_major_index(int i, int j, int ncols) { return i * ncols + j; }
int col_major_index(int i, int j, int nrows) { return j * nrows + i; }

// --- Part 4: the general stride formula both of the above are special
// cases of ---
int strided_index(int i, int j, int row_stride, int col_stride) {
    return i * row_stride + j * col_stride;
}

// --- Part 3: physical transpose -- actually moves bytes, doesn't just
// reinterpret indices ---
std::vector<float> transpose(const std::vector<float>& M, int n) {
    std::vector<float> T(n * n);
    for (int i = 0; i < n; ++i) {
        for (int j = 0; j < n; ++j) {
            T[j * n + i] = M[i * n + j]; // swap the role of i and j
        }
    }
    return T;
}

// --- Part 5: the two matmul variants that differ only in B's access
// pattern ---
void matmul_naive(const std::vector<float>& A, const std::vector<float>& B,
                   std::vector<float>& C, int n) {
    for (int i = 0; i < n; ++i) {
        for (int j = 0; j < n; ++j) {
            float sum = 0.0f;
            for (int k = 0; k < n; ++k) {
                sum += A[i * n + k] * B[k * n + j]; // B stride n, non-contiguous
            }
            C[i * n + j] = sum;
        }
    }
}

void matmul_transposed_B(const std::vector<float>& A, const std::vector<float>& Bt,
                          std::vector<float>& C, int n) {
    for (int i = 0; i < n; ++i) {
        for (int j = 0; j < n; ++j) {
            float sum = 0.0f;
            for (int k = 0; k < n; ++k) {
                sum += A[i * n + k] * Bt[j * n + k]; // Bt stride 1, contiguous
            }
            C[i * n + j] = sum;
        }
    }
}

static double median_ms(std::vector<double>& times) {
    std::sort(times.begin(), times.end());
    return times[times.size() / 2];
}

int main(int argc, char** argv) {
    int n = argc > 1 ? atoi(argv[1]) : 256;

    // --- Part 1/2: same logical layout, two index formulas ---
    printf("Part 1: row-major vs column-major indexing for a 3x3 matrix\n");
    printf("  logical position (row=1, col=2):\n");
    printf("    row-major index   = %d\n", row_major_index(1, 2, 3));
    printf("    column-major index = %d\n\n", col_major_index(1, 2, 3));

    // --- Part 3: transpose is self-inverting -- transpose it twice, get
    // the original back ---
    printf("Part 3: transpose(transpose(M)) should equal M\n");
    std::vector<float> M = {1, 2, 3, 4, 5, 6, 7, 8, 9}; // 3x3
    std::vector<float> Mt = transpose(M, 3);
    std::vector<float> Mtt = transpose(Mt, 3);
    bool double_transpose_ok = true;
    for (int i = 0; i < 9; ++i) {
        if (std::fabs(M[i] - Mtt[i]) > 1e-6f) double_transpose_ok = false;
    }
    printf("  M   = [1,2,3, 4,5,6, 7,8,9]\n");
    printf("  Mt  = [%.0f,%.0f,%.0f, %.0f,%.0f,%.0f, %.0f,%.0f,%.0f]\n",
           Mt[0], Mt[1], Mt[2], Mt[3], Mt[4], Mt[5], Mt[6], Mt[7], Mt[8]);
    printf("  Verification: double_transpose_equals_original = %s\n\n",
           double_transpose_ok ? "PASS" : "FAIL");

    // --- Part 4: stride formula reproduces both special cases ---
    printf("Part 4: strided_index reproduces both layouts\n");
    bool stride_matches_row_major = (strided_index(1, 2, 3, 1) == row_major_index(1, 2, 3));
    bool stride_matches_col_major = (strided_index(1, 2, 1, 3) == col_major_index(1, 2, 3));
    printf("  strided_index(1,2, row_stride=3, col_stride=1) = %d (row-major form)\n",
           strided_index(1, 2, 3, 1));
    printf("  strided_index(1,2, row_stride=1, col_stride=3) = %d (column-major form)\n",
           strided_index(1, 2, 1, 3));
    printf("  Verification: stride_formula_matches_both_layouts = %s\n\n",
           (stride_matches_row_major && stride_matches_col_major) ? "PASS" : "FAIL");

    // --- Part 5: the real payoff -- does contiguous access actually matter? ---
    printf("Part 5: naive B access (stride n) vs transposed B access (stride 1), N=%d\n", n);
    std::vector<float> A(n * n), B(n * n), C1(n * n), C2(n * n);
    srand(42);
    for (int i = 0; i < n * n; ++i) {
        A[i] = (rand() % 1000) / 1000.0f;
        B[i] = (rand() % 1000) / 1000.0f;
    }
    std::vector<float> Bt = transpose(B, n);

    std::vector<double> naive_times, transposed_times;
    for (int t = 0; t < 5; ++t) {
        auto t0 = std::chrono::high_resolution_clock::now();
        matmul_naive(A, B, C1, n);
        auto t1 = std::chrono::high_resolution_clock::now();
        naive_times.push_back(std::chrono::duration<double, std::milli>(t1 - t0).count());
    }
    for (int t = 0; t < 5; ++t) {
        auto t0 = std::chrono::high_resolution_clock::now();
        matmul_transposed_B(A, Bt, C2, n);
        auto t1 = std::chrono::high_resolution_clock::now();
        transposed_times.push_back(std::chrono::duration<double, std::milli>(t1 - t0).count());
    }

    double naive_ms = median_ms(naive_times);
    double transposed_ms = median_ms(transposed_times);

    float max_diff = 0.0f;
    for (int i = 0; i < n * n; ++i) max_diff = std::fmax(max_diff, std::fabs(C1[i] - C2[i]));

    printf("  naive (stride n) median:       %.2f ms\n", naive_ms);
    printf("  transposed (stride 1) median:  %.2f ms\n", transposed_ms);
    printf("  speedup: %.2fx\n", naive_ms / transposed_ms);
    printf("  max_diff between results: %.8f\n", max_diff);
    bool results_match = max_diff < 1e-3f;
    printf("  Verification: results_match = %s\n\n", results_match ? "PASS" : "FAIL");

    printf("Part 6: this is lesson 2.2's exercise, answered\n");
    printf("  transposing B costs one O(N^2) pass up front, then every\n");
    printf("  read inside the O(N^3) inner loop becomes contiguous instead\n");
    printf("  of jumping n floats at a time. the layout of the data changed,\n");
    printf("  not the math -- results_match confirms that directly.\n");

    bool all_pass = double_transpose_ok && stride_matches_row_major &&
                     stride_matches_col_major && results_match;
    printf("\nVerification: all_checks = %s\n", all_pass ? "PASS" : "FAIL");
    return all_pass ? 0 : 1;
}
