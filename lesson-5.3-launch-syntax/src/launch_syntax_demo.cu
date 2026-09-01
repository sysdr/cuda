// launch_syntax_demo.cu
// Lesson 5.3 -- launching a kernel: the <<<grid, block>>> syntax, in
// full. Lessons 5.1 and 5.2 used the first two positions of this
// syntax without explaining that there are actually four. This lesson
// fills in the other two: dynamic shared memory size, and stream.
#include <cstdio>
#include <cstring>
#include <vector>
#include "../common/cuda_check.cuh"

// --- Part 1: the two forms of a launch are identical --------------
__global__ void trivial_write(int* out) {
    out[threadIdx.x] = threadIdx.x;
}

// --- Part 2: dynamic shared memory -- sized at launch time, not at
// compile time. extern __shared__ declares an array with NO size in
// the source; the actual byte count comes from the kernel launch's
// third argument. Reversing each block's chunk of data is a small,
// genuinely useful reason to stage data through shared memory rather
// than just decoration. ---
__global__ void reverse_block_dynamic(int* data, int n) {
    extern __shared__ int sdata[]; // size = whatever the launch specifies

    int tid = threadIdx.x;
    int gid = blockIdx.x * blockDim.x + tid;

    if (gid < n) sdata[tid] = data[gid];
    __syncthreads(); // every thread's load must finish before any read

    if (gid < n) {
        data[gid] = sdata[blockDim.x - 1 - tid]; // reversed within THIS block only
    }
}

int main() {
    const int n = 1024;
    const int block_size = 256;
    const int grid_size = n / block_size; // divides evenly: 4 blocks

    // --- Part 1: shorthand vs fully explicit launch, same result ---
    printf("Part 1: the launch syntax has four positions, not two\n");
    printf("  kernel<<<grid, block>>>(...)                    -- shorthand\n");
    printf("  kernel<<<grid, block, 0, 0>>>(...)               -- fully explicit\n");
    printf("  the missing two default to 0 bytes of dynamic shared\n");
    printf("  memory and the default stream -- identical launches.\n\n");

    int* d_a = nullptr;
    int* d_b = nullptr;
    CUDA_CHECK(cudaMalloc(&d_a, block_size * sizeof(int)));
    CUDA_CHECK(cudaMalloc(&d_b, block_size * sizeof(int)));

    trivial_write<<<1, block_size>>>(d_a);
    CUDA_CHECK(cudaGetLastError());
    trivial_write<<<1, block_size, 0, 0>>>(d_b);
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaDeviceSynchronize());

    std::vector<int> h_a(block_size), h_b(block_size);
    CUDA_CHECK(cudaMemcpy(h_a.data(), d_a, block_size * sizeof(int), cudaMemcpyDeviceToHost));
    CUDA_CHECK(cudaMemcpy(h_b.data(), d_b, block_size * sizeof(int), cudaMemcpyDeviceToHost));
    bool shorthand_matches_explicit = (memcmp(h_a.data(), h_b.data(), block_size * sizeof(int)) == 0);
    printf("  Verification: shorthand_equals_explicit_launch = %s\n\n",
           shorthand_matches_explicit ? "PASS" : "FAIL");
    CUDA_CHECK(cudaFree(d_a));
    CUDA_CHECK(cudaFree(d_b));

    // --- Part 2: dynamic shared memory, sized at launch time ---
    printf("Part 2: the third argument -- dynamic shared memory, in bytes\n");
    std::vector<int> h_data(n);
    for (int i = 0; i < n; ++i) h_data[i] = i;

    int* d_data = nullptr;
    CUDA_CHECK(cudaMalloc(&d_data, n * sizeof(int)));
    CUDA_CHECK(cudaMemcpy(d_data, h_data.data(), n * sizeof(int), cudaMemcpyHostToDevice));

    size_t shared_bytes = block_size * sizeof(int); // exactly what the kernel needs
    printf("  block_size * sizeof(int) = %zu bytes of shared memory requested\n", shared_bytes);
    reverse_block_dynamic<<<grid_size, block_size, shared_bytes>>>(d_data, n);
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaDeviceSynchronize());

    std::vector<int> h_result(n);
    CUDA_CHECK(cudaMemcpy(h_result.data(), d_data, n * sizeof(int), cudaMemcpyDeviceToHost));

    // expected: each block's own 256-element chunk reversed independently
    std::vector<int> expected(n);
    for (int b = 0; b < grid_size; ++b) {
        for (int t = 0; t < block_size; ++t) {
            expected[b * block_size + t] = h_data[b * block_size + (block_size - 1 - t)];
        }
    }
    bool reverse_correct = (h_result == expected);
    printf("  block 0: data[0]=%d data[255]=%d (expected 255, 0)\n", h_result[0], h_result[255]);
    printf("  block 1: data[256]=%d data[511]=%d (expected 511, 256 -- reversal restarts per block)\n",
           h_result[256], h_result[511]);
    printf("  Verification: per_block_reversal_correct = %s\n\n", reverse_correct ? "PASS" : "FAIL");
    CUDA_CHECK(cudaFree(d_data));

    // --- Part 3: the fourth argument -- which stream ---
    printf("Part 3: the fourth argument -- which stream to launch on\n");
    cudaStream_t stream;
    CUDA_CHECK(cudaStreamCreate(&stream));

    int* d_stream_test = nullptr;
    CUDA_CHECK(cudaMalloc(&d_stream_test, block_size * sizeof(int)));
    trivial_write<<<1, block_size, 0, stream>>>(d_stream_test);
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaStreamSynchronize(stream)); // sync THIS stream, not the whole device

    std::vector<int> h_stream_result(block_size);
    CUDA_CHECK(cudaMemcpy(h_stream_result.data(), d_stream_test, block_size * sizeof(int), cudaMemcpyDeviceToHost));
    bool stream_launch_correct = (h_stream_result == h_a);
    printf("  launched on an explicit, non-default stream instead of stream 0\n");
    printf("  Verification: explicit_stream_launch_correct = %s\n", stream_launch_correct ? "PASS" : "FAIL");
    printf("  the actual benefit of streams -- overlapping work -- is Module 8's\n");
    printf("  subject. this is only the syntax slot they occupy in the launch.\n\n");

    CUDA_CHECK(cudaStreamDestroy(stream));
    CUDA_CHECK(cudaFree(d_stream_test));

    bool all_pass = shorthand_matches_explicit && reverse_correct && stream_launch_correct;
    printf("Verification: all_checks = %s\n", all_pass ? "PASS" : "FAIL");
    return all_pass ? 0 : 1;
}
