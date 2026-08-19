// thread_hierarchy_demo.cu
// Lesson 5.1 -- threads, blocks, and grids: the three-level hierarchy.
// Module 5's opener, and the first kernel launch in this entire
// course. Twenty-four lessons, four modules, zero kernels -- until
// this file.
#include <cstdio>
#include <vector>
#include "../common/cuda_check.cuh"

// --- the first __global__ function in this course ---
// Every thread that runs this computes exactly one thing: its own
// position in the flat grid of all threads launched, and writes that
// position into out[]. Nothing else. This is deliberately the
// simplest possible kernel that still makes the hierarchy concrete
// and independently verifiable.
__global__ void write_thread_index(int* out, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    // boundary guard -- you will see this exact pattern again in every
    // kernel from here through lesson 7.5 onward. n rarely divides
    // evenly into your block size, so some threads at the tail end of
    // the last block exist but have no valid array element to write.
    if (i < n) {
        out[i] = i;
    }
}

int main() {
    const int n = 4096;
    const int block_size = 256;
    const int grid_size = (n + block_size - 1) / block_size; // ceiling division

    printf("Part 1: the launch configuration\n");
    printf("  n (elements needed):     %d\n", n);
    printf("  block size (threads):    %d\n", block_size);
    printf("  grid size (blocks):      %d\n", grid_size);
    printf("  total threads launched:  %d\n", grid_size * block_size);
    printf("  threads with nothing to do (boundary): %d\n\n",
           grid_size * block_size - n);

    int* d_out = nullptr;
    CUDA_CHECK(cudaMalloc(&d_out, n * sizeof(int)));

    printf("Part 2: launching -- the first kernel this course has run\n");
    write_thread_index<<<grid_size, block_size>>>(d_out, n);

    // A kernel launch is asynchronous -- the CPU doesn't wait for it.
    // cudaGetLastError() catches launch CONFIGURATION problems (a bad
    // grid or block size, for example) that the driver can detect
    // immediately, before the kernel has necessarily finished running.
    CUDA_CHECK(cudaGetLastError());

    // cudaDeviceSynchronize() blocks until the kernel actually
    // finishes, and its return value catches RUNTIME errors that only
    // show up while the kernel is executing (an out-of-bounds write,
    // for instance). Skip this and you can't tell "launched
    // successfully" from "ran and crashed" -- both look identical from
    // the host's point of view until you synchronize.
    CUDA_CHECK(cudaDeviceSynchronize());
    printf("  launch configuration accepted, kernel finished executing\n\n");

    std::vector<int> h_out(n);
    CUDA_CHECK(cudaMemcpy(h_out.data(), d_out, n * sizeof(int), cudaMemcpyDeviceToHost));

    printf("Part 3: verifying every one of the %d threads computed the right answer\n", n);
    bool all_correct = true;
    int first_wrong = -1;
    for (int i = 0; i < n; ++i) {
        if (h_out[i] != i) {
            all_correct = false;
            if (first_wrong == -1) first_wrong = i;
        }
    }
    printf("  out[0]    = %d (expected 0)\n", h_out[0]);
    printf("  out[255]  = %d (expected 255 -- last thread of block 0)\n", h_out[255]);
    printf("  out[256]  = %d (expected 256 -- first thread of block 1)\n", h_out[256]);
    printf("  out[%d] = %d (expected %d -- last element)\n", n - 1, h_out[n - 1], n - 1);

    if (!all_correct) {
        printf("  first wrong index: %d, got %d\n", first_wrong, h_out[first_wrong]);
    }
    printf("  Verification: every_thread_wrote_its_own_index = %s\n\n",
           all_correct ? "PASS" : "FAIL");

    printf("Part 4: what just happened, structurally\n");
    printf("  %d threads ran. each one asked two questions -- which block\n", grid_size * block_size);
    printf("  am I in (blockIdx.x), and where am I within that block\n");
    printf("  (threadIdx.x) -- and combined them into one global position.\n");
    printf("  no two threads computed the same i. that's the entire\n");
    printf("  hierarchy, doing real work, for the first time in this course.\n");

    CUDA_CHECK(cudaFree(d_out));
    return all_correct ? 0 : 1;
}
