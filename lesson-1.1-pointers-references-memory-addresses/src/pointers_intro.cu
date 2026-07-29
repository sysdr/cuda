// pointers_intro.cu
// Lesson 1.1 -- pointers, references, and memory addresses, with the CUDA
// wrinkle: a host pointer and a device pointer are both just numbers, and
// the compiler will let you mix them up. This program shows what actually
// distinguishes them and how to check.
//
// No kernel launch here on purpose -- that syntax belongs to Module 5.
// This lesson is scoped to pointers and memory alone.
#include <cstdio>
#include <cstring>
#include "../common/cuda_check.cuh"

// Set to 1 locally if you want to see what dereferencing a device pointer
// from host code actually does. It is undefined behavior -- on most
// systems it segfaults immediately, which is the safest way it can fail.
// Left off by default so the lesson build never crashes.
#define DEMONSTRATE_INVALID_HOST_DEREF 0

int main() {
    // --- Part 1: a plain host variable and its address ---
    int x = 42;
    int* host_ptr = &x;
    printf("Part 1: host variable\n");
    printf("  x itself:        %d\n", x);
    printf("  address of x:    %p\n", (void*)&x);
    printf("  host_ptr holds:  %p\n", (void*)host_ptr);
    printf("  *host_ptr:       %d\n\n", *host_ptr);

    // --- Part 2: pointer arithmetic over a host array ---
    int host_array[5] = {10, 20, 30, 40, 50};
    printf("Part 2: pointer arithmetic on a 5-int host array\n");
    for (int i = 0; i < 5; ++i) {
        int* p = host_array + i;
        printf("  host_array[%d] at %p = %d\n", i, (void*)p, *p);
    }
    printf("  each step is %zu bytes apart (sizeof(int))\n\n", sizeof(int));

    // --- Part 3: a device pointer is also just a number ---
    int* device_ptr = nullptr;
    CUDA_CHECK(cudaMalloc(&device_ptr, 5 * sizeof(int)));
    printf("Part 3: a device pointer looks the same as a host pointer\n");
    printf("  host_ptr    (host memory)   = %p\n", (void*)host_ptr);
    printf("  device_ptr  (device memory) = %p\n", (void*)device_ptr);
    printf("  nothing about the number itself tells you which is which\n\n");

    // --- Part 4: the actual way to tell them apart ---
    cudaPointerAttributes host_attr;
    cudaPointerAttributes device_attr;
    // Host stack pointers are not CUDA-registered, so this call will report
    // cudaErrorInvalidValue for host_ptr on some driver versions instead of
    // populating attr.type -- that failure is itself the answer, so we
    // treat it as informative rather than fatal here only.
    cudaError_t host_query = cudaPointerGetAttributes(&host_attr, host_ptr);
    CUDA_CHECK(cudaPointerGetAttributes(&device_attr, device_ptr));

    printf("Part 4: asking CUDA directly what kind of pointer each one is\n");
    if (host_query == cudaSuccess) {
        printf("  host_ptr   -> cudaMemoryType = %d (0=unregistered,1=host,2=device,3=managed)\n",
               (int)host_attr.type);
    } else {
        printf("  host_ptr   -> cudaPointerGetAttributes returned an error (%s)\n",
               cudaGetErrorString(host_query));
        printf("               that error IS the answer: this pointer was never registered with CUDA\n");
        cudaGetLastError(); // clear the sticky error before continuing
    }
    printf("  device_ptr -> cudaMemoryType = %d (0=unregistered,1=host,2=device,3=managed)\n\n",
           (int)device_attr.type);

    // --- Part 5: moving data across the boundary correctly ---
    int result_array[5] = {0};
    CUDA_CHECK(cudaMemcpy(device_ptr, host_array, 5 * sizeof(int), cudaMemcpyHostToDevice));
    CUDA_CHECK(cudaMemcpy(result_array, device_ptr, 5 * sizeof(int), cudaMemcpyDeviceToHost));

    bool match = (memcmp(host_array, result_array, sizeof(host_array)) == 0);
    printf("Part 5: round-trip host -> device -> host\n");
    for (int i = 0; i < 5; ++i) {
        printf("  result_array[%d] = %d\n", i, result_array[i]);
    }
    printf("Verification: round_trip_matches_original = %s\n", match ? "PASS" : "FAIL");

#if DEMONSTRATE_INVALID_HOST_DEREF
    printf("\nPart 6: dereferencing device_ptr directly from host code...\n");
    printf("about to read: %d\n", *device_ptr); // undefined behavior, likely a crash
#endif

    CUDA_CHECK(cudaFree(device_ptr));
    return match ? 0 : 1;
}
