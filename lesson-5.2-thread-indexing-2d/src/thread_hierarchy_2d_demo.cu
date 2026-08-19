// thread_hierarchy_2d_demo.cu
// Lesson 5.2 -- threadIdx, blockIdx, blockDim, gridDim, and the global
// index formula, extended from lesson 5.1's single dimension into two.
// Same 4096 threads, same 16 blocks, same 256 threads per block as
// lesson 5.1 -- reshaped into a 2D grid instead of a 1D line, because
// that's what real problems like images and matrices actually need.
#include <cstdio>
#include <vector>
#include "../common/cuda_check.cuh"

// --- the 2D analog of lesson 5.1's kernel ---
// Every thread computes its own (row, col), then flattens that into
// the same kind of single index lesson 5.1 used -- row-major, the
// layout lesson 2.3 already covered. This exact row/col computation
// is what lesson 7.4 and 7.5's matmul kernels use, unchanged.
__global__ void write_2d_index(int* out, int width, int height) {
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    if (row < height && col < width) {
        out[row * width + col] = row * width + col;
    }
}

int main() {
    const int width = 64;
    const int height = 64;
    const dim3 block(16, 16);
    const dim3 grid((width + block.x - 1) / block.x, (height + block.y - 1) / block.y);

    printf("Part 1: the same 4096 threads as lesson 5.1, reshaped into 2D\n");
    printf("  width x height:          %d x %d = %d elements\n", width, height, width * height);
    printf("  block:                   (%d, %d) = %d threads\n", block.x, block.y, block.x * block.y);
    printf("  grid:                    (%d, %d) = %d blocks\n", grid.x, grid.y, grid.x * grid.y);
    printf("  total threads launched:  %d\n\n", grid.x * grid.y * block.x * block.y);

    int* d_out = nullptr;
    CUDA_CHECK(cudaMalloc(&d_out, width * height * sizeof(int)));

    printf("Part 2: launching with a 2D block and a 2D grid\n");
    write_2d_index<<<grid, block>>>(d_out, width, height);
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaDeviceSynchronize());
    printf("  launch configuration accepted, kernel finished executing\n\n");

    std::vector<int> h_out(width * height);
    CUDA_CHECK(cudaMemcpy(h_out.data(), d_out, width * height * sizeof(int), cudaMemcpyDeviceToHost));

    printf("Part 3: verifying the row-major flattening is correct\n");
    bool all_correct = true;
    int first_wrong = -1;
    for (int i = 0; i < width * height; ++i) {
        if (h_out[i] != i) {
            all_correct = false;
            if (first_wrong == -1) first_wrong = i;
        }
    }
    printf("  out[0]   = %d (expected 0   -- row 0, col 0)\n", h_out[0]);
    printf("  out[63]  = %d (expected 63  -- row 0, col 63, last of row 0)\n", h_out[63]);
    printf("  out[64]  = %d (expected 64  -- row 1, col 0, first of row 1)\n", h_out[64]);
    printf("  out[4095]= %d (expected 4095 -- row 63, col 63, last element)\n", h_out[width * height - 1]);
    if (!all_correct) {
        printf("  first wrong flat index: %d, got %d\n", first_wrong, h_out[first_wrong]);
    }
    printf("  Verification: row_major_flattening_correct = %s\n\n", all_correct ? "PASS" : "FAIL");

    printf("Part 4: proving it's genuinely 2D, not 1D in disguise\n");
    // Spot-check a specific (row, col) pair mid-grid by re-deriving
    // what its flat index SHOULD be, independent of the kernel, and
    // confirming the two agree.
    int check_row = 37, check_col = 22;
    int expected_flat = check_row * width + check_col;
    int actual_value = h_out[expected_flat];
    printf("  (row=%d, col=%d) should flatten to index %d\n", check_row, check_col, expected_flat);
    printf("  out[%d] = %d\n", expected_flat, actual_value);
    bool spot_check_ok = (actual_value == expected_flat);
    printf("  Verification: arbitrary_2d_position_correct = %s\n\n", spot_check_ok ? "PASS" : "FAIL");

    printf("Part 5: this is exactly what lesson 7.4 and 7.5's matmul kernels do\n");
    printf("  row = blockIdx.y * blockDim.y + threadIdx.y;\n");
    printf("  col = blockIdx.x * blockDim.x + threadIdx.x;\n");
    printf("  C[row * n + col] = ...\n");
    printf("  same two lines, same row-major flattening -- this lesson's kernel\n");
    printf("  and a real matmul kernel differ only in what they write, not in\n");
    printf("  how they figure out where to write it.\n");

    bool all_pass = all_correct && spot_check_ok;
    printf("\nVerification: all_checks = %s\n", all_pass ? "PASS" : "FAIL");

    CUDA_CHECK(cudaFree(d_out));
    return all_pass ? 0 : 1;
}
