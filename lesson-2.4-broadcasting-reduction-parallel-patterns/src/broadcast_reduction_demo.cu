// broadcast_reduction_demo.cu
// Lesson 2.4 -- broadcasting and reduction as parallel patterns.
// Module 2's closer. Two shapes of computation that show up constantly
// from here on: broadcasting expands a smaller array across a larger
// one with no coordination needed between outputs, reduction collapses
// many values into one and needs every partial result combined
// eventually. That difference in coordination need is exactly why
// lesson 7.6's parallel reduction is a harder kernel to write correctly
// than a simple elementwise kernel would be -- foreshadowed here, not
// yet built.
//
// No CUDA calls in this file -- same precedent as 1.3, 2.1, 2.2, 2.3.
#include <cstdio>
#include <cmath>
#include <vector>
#include <algorithm>

// --- Part 1: broadcasting a scalar across a vector ---
std::vector<float> broadcast_add_scalar(const std::vector<float>& v, float s) {
    std::vector<float> out(v.size());
    for (size_t i = 0; i < v.size(); ++i) out[i] = v[i] + s;
    return out;
}

// --- Part 2: broadcasting a row vector across every row of a matrix --
// the exact pattern behind adding a bias vector to a linear layer's
// output, which is Module 13 territory later in this course ---
std::vector<float> broadcast_add_row(const std::vector<float>& M, int rows, int cols,
                                      const std::vector<float>& bias) {
    std::vector<float> out(rows * cols);
    for (int i = 0; i < rows; ++i) {
        for (int j = 0; j < cols; ++j) {
            out[i * cols + j] = M[i * cols + j] + bias[j]; // bias reused for every row
        }
    }
    return out;
}

// --- Part 3: reduction -- many values collapse into one ---
float reduce_sum(const std::vector<float>& v) {
    float total = 0.0f;
    for (float x : v) total += x;
    return total;
}

float reduce_max(const std::vector<float>& v) {
    float m = v[0];
    for (float x : v) m = std::fmax(m, x);
    return m;
}

// --- Part 4: reduction plus elementwise multiply IS the dot product
// from lesson 2.1 -- proved directly, not just asserted ---
float dot_n(const std::vector<float>& a, const std::vector<float>& b) {
    float sum = 0.0f;
    for (size_t i = 0; i < a.size(); ++i) sum += a[i] * b[i];
    return sum;
}

float dot_via_multiply_then_reduce(const std::vector<float>& a, const std::vector<float>& b) {
    std::vector<float> products(a.size());
    for (size_t i = 0; i < a.size(); ++i) products[i] = a[i] * b[i];
    return reduce_sum(products);
}

int main() {
    // --- Part 1 ---
    printf("Part 1: broadcasting a scalar across a vector\n");
    std::vector<float> v = {1, 2, 3, 4, 5};
    std::vector<float> v_plus_10 = broadcast_add_scalar(v, 10.0f);
    printf("  v = [1,2,3,4,5], v + 10 = [%.0f,%.0f,%.0f,%.0f,%.0f]\n\n",
           v_plus_10[0], v_plus_10[1], v_plus_10[2], v_plus_10[3], v_plus_10[4]);

    // --- Part 2 ---
    printf("Part 2: broadcasting a row vector across every row of a matrix\n");
    std::vector<float> M = {1, 2, 3, 4, 5, 6}; // 2x3
    std::vector<float> bias = {10, 20, 30};
    std::vector<float> M_biased = broadcast_add_row(M, 2, 3, bias);
    printf("  M = [[1,2,3],[4,5,6]], bias = [10,20,30]\n");
    printf("  M + bias = [[%.0f,%.0f,%.0f],[%.0f,%.0f,%.0f]]\n\n",
           M_biased[0], M_biased[1], M_biased[2], M_biased[3], M_biased[4], M_biased[5]);
    bool broadcast_ok = (M_biased[0]==11 && M_biased[1]==22 && M_biased[2]==33 &&
                         M_biased[3]==14 && M_biased[4]==25 && M_biased[5]==36);
    printf("  Verification: broadcast_row_correct = %s\n\n", broadcast_ok ? "PASS" : "FAIL");

    // --- Part 3 ---
    printf("Part 3: reduction -- sum and max of the same data\n");
    std::vector<float> data = {3, 1, 4, 1, 5, 9, 2, 6};
    printf("  data = [3,1,4,1,5,9,2,6]\n");
    printf("  reduce_sum(data) = %.1f (hand check: 3+1+4+1+5+9+2+6 = 31)\n", reduce_sum(data));
    printf("  reduce_max(data) = %.1f\n\n", reduce_max(data));
    bool reduce_ok = (reduce_sum(data) == 31.0f && reduce_max(data) == 9.0f);
    printf("  Verification: reduce_sum_and_max_correct = %s\n\n", reduce_ok ? "PASS" : "FAIL");

    // --- Part 4: prove multiply-then-reduce equals dot_n ---
    printf("Part 4: elementwise multiply + reduce_sum should equal lesson 2.1's dot_n\n");
    std::vector<float> a = {1, 2, 3};
    std::vector<float> b = {4, 5, 6};
    float direct = dot_n(a, b);
    float via_reduce = dot_via_multiply_then_reduce(a, b);
    printf("  dot_n(a, b) = %.1f\n", direct);
    printf("  reduce_sum(a .* b) = %.1f\n", via_reduce);
    bool reduce_matches_dot = std::fabs(direct - via_reduce) < 1e-5f;
    printf("  Verification: reduce_equals_dot_product = %s\n\n", reduce_matches_dot ? "PASS" : "FAIL");

    // --- Part 5: does summation order matter? ---
    printf("Part 5: does the order you add numbers in change the answer?\n");
    std::vector<float> ordered = {0.1f, 0.2f, 0.3f, 0.4f, 0.5f, 0.6f, 0.7f, 0.8f};
    float forward_sum = 0.0f;
    for (float x : ordered) forward_sum += x;
    float reverse_sum = 0.0f;
    for (auto it = ordered.rbegin(); it != ordered.rend(); ++it) reverse_sum += *it;
    // pairwise tree order: sum adjacent pairs first, then combine pairs of pairs
    float p0 = ordered[0]+ordered[1], p1 = ordered[2]+ordered[3];
    float p2 = ordered[4]+ordered[5], p3 = ordered[6]+ordered[7];
    float tree_sum = (p0 + p1) + (p2 + p3);
    printf("  forward order:  %.6f\n", forward_sum);
    printf("  reverse order:  %.6f\n", reverse_sum);
    printf("  tree order:     %.6f\n", tree_sum);
    float max_spread = std::fmax(std::fabs(forward_sum - reverse_sum),
                                  std::fabs(forward_sum - tree_sum));
    printf("  max spread between orderings: %.8f\n", max_spread);
    bool orderings_close_enough = max_spread < 1e-5f;
    printf("  Verification: summation_order_within_tolerance = %s\n", orderings_close_enough ? "PASS" : "FAIL");
    printf("  (not bit-identical -- floating point addition is not strictly\n");
    printf("  associative. close enough here, but see the lesson text.)\n\n");

    bool all_pass = broadcast_ok && reduce_ok && reduce_matches_dot && orderings_close_enough;
    printf("Verification: all_checks = %s\n", all_pass ? "PASS" : "FAIL");
    return all_pass ? 0 : 1;
}
