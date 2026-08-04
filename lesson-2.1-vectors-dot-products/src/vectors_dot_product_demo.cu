// vectors_dot_product_demo.cu
// Lesson 2.1 -- vectors and dot products. Module 2's opener, and the
// last purely conceptual lesson before Module 2 starts building toward
// matrix multiply. No kernel launch -- still Phase 1 territory, same
// scoping used throughout Module 1.
#include <cstdio>
#include <cmath>
#include <vector>
#include "../common/cuda_check.cuh"

// --- Part 1: a 3-component vector, the geometric case ---
struct Vec3 {
    float x, y, z;
};

float dot3(const Vec3& a, const Vec3& b) {
    return a.x * b.x + a.y * b.y + a.z * b.z;
}

float magnitude3(const Vec3& v) {
    return std::sqrt(dot3(v, v));
}

// --- Part 3: the general N-dimensional case, the one matmul actually uses ---
float dot_n(const std::vector<float>& a, const std::vector<float>& b) {
    float sum = 0.0f;
    for (size_t i = 0; i < a.size(); ++i) {
        sum += a[i] * b[i];
    }
    return sum;
}

int main() {
    printf("Part 1: dot product of two 3D vectors\n");
    Vec3 a = {1.0f, 2.0f, 3.0f};
    Vec3 b = {4.0f, 5.0f, 6.0f};
    float result = dot3(a, b);
    printf("  a = (%.1f, %.1f, %.1f)\n", a.x, a.y, a.z);
    printf("  b = (%.1f, %.1f, %.1f)\n", b.x, b.y, b.z);
    printf("  dot(a, b) = 1*4 + 2*5 + 3*6 = %.1f\n\n", result);

    printf("Part 2: two properties every dot product implementation should satisfy\n");
    Vec3 right = {1.0f, 0.0f, 0.0f};
    Vec3 up    = {0.0f, 1.0f, 0.0f};
    float perpendicular_dot = dot3(right, up);
    printf("  perpendicular vectors: dot((1,0,0), (0,1,0)) = %.4f\n", perpendicular_dot);

    Vec3 v = {3.0f, 4.0f, 0.0f};
    float self_dot = dot3(v, v);
    float mag = magnitude3(v);
    float mag_squared = mag * mag;
    printf("  dot(v, v) = %.4f, magnitude(v)^2 = %.4f\n", self_dot, mag_squared);

    bool perpendicular_ok = std::fabs(perpendicular_dot - 0.0f) < 1e-5f;
    bool self_dot_ok = std::fabs(self_dot - mag_squared) < 1e-4f;
    printf("  Verification: perpendicular_vectors_dot_to_zero = %s\n",
           perpendicular_ok ? "PASS" : "FAIL");
    printf("  Verification: self_dot_equals_magnitude_squared = %s\n\n",
           self_dot_ok ? "PASS" : "FAIL");

    printf("Part 3: the N-dimensional case -- what matmul actually calls\n");
    std::vector<float> row = {1.0f, 2.0f, 3.0f};
    std::vector<float> col = {4.0f, 5.0f, 6.0f};
    float dot_result = dot_n(row, col);
    printf("  dot_n({1,2,3}, {4,5,6}) = %.1f\n", dot_result);
    bool matches_hand_calc = std::fabs(dot_result - 32.0f) < 1e-5f;
    printf("  Verification: matches_hand_calculation = %s\n\n",
           matches_hand_calc ? "PASS" : "FAIL");

    printf("Part 4: this is not a new idea -- you already used it\n");
    printf("  lesson 7.5's matmul_tiled_kernel computes exactly this, once per\n");
    printf("  output element: C[row][col] = dot_n(row_of_A, col_of_B). every\n");
    printf("  multiply-add in that kernel's inner loop was a dot product,\n");
    printf("  computed one term at a time instead of in a single function call.\n");

    bool all_pass = perpendicular_ok && self_dot_ok && matches_hand_calc;
    printf("\nVerification: all_checks = %s\n", all_pass ? "PASS" : "FAIL");
    return all_pass ? 0 : 1;
}
