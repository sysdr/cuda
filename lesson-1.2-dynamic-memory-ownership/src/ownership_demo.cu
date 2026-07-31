// ownership_demo.cu
// Lesson 1.2 -- dynamic memory: malloc/new/delete, and who owns a piece
// of memory once a pointer to it exists in more than one place.
//
// Same no-kernel-launch scoping as 1.1. This lesson is about allocators
// and ownership, not execution.
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include "../common/cuda_check.cuh"

// Off by default -- these are genuine undefined-behavior demonstrations.
// Flip one on at a time locally if you want to see the actual failure.
#define DEMONSTRATE_MISMATCHED_DELETE 0
#define DEMONSTRATE_HOST_FREE_ON_DEVICE_PTR 0

// --- Part 1: a hand-rolled allocation counter for malloc/free ---
// This is not a real leak detector -- it's twelve lines that make one
// point: every malloc needs exactly one free, and nothing enforces that
// for you.
static int g_malloc_count = 0;

void* tracked_malloc(size_t bytes) {
    g_malloc_count++;
    return malloc(bytes);
}

void tracked_free(void* ptr) {
    g_malloc_count--;
    free(ptr);
}

// --- Part 2: a struct with a constructor and destructor, to show what
// new/delete do that malloc/free don't ---
struct Loud {
    int id;
    Loud(int i) : id(i) { printf("  Loud(%d) constructed\n", id); }
    ~Loud() { printf("  Loud(%d) destroyed\n", id); }
};

// --- Part 5: RAII wrapper around device memory. The constructor
// allocates, the destructor frees. Whoever owns this object owns the
// device memory, automatically, with no separate bookkeeping. ---
struct DeviceBuffer {
    int* ptr = nullptr;
    size_t count = 0;
    static int live_count; // how many DeviceBuffer objects currently exist

    explicit DeviceBuffer(size_t n) : count(n) {
        CUDA_CHECK(cudaMalloc(&ptr, n * sizeof(int)));
        live_count++;
    }
    ~DeviceBuffer() {
        if (ptr) {
            cudaFree(ptr); // destructors should not throw or exit; log only
            live_count--;
        }
    }
    // Not copyable -- a naive copy would let two DeviceBuffer objects
    // both believe they own the same pointer, and both would free it.
    DeviceBuffer(const DeviceBuffer&) = delete;
    DeviceBuffer& operator=(const DeviceBuffer&) = delete;
};
int DeviceBuffer::live_count = 0;

int main() {
    // --- Part 1: malloc / free, and a counter that has to balance ---
    printf("Part 1: malloc/free ownership\n");
    void* a = tracked_malloc(64);
    void* b = tracked_malloc(128);
    tracked_free(a);
    tracked_free(b);
    printf("  allocations outstanding: %d\n", g_malloc_count);
    printf("  Verification: malloc_free_balanced = %s\n\n",
           g_malloc_count == 0 ? "PASS" : "FAIL");

    // --- Part 2: new/delete actually run constructors and destructors ---
    printf("Part 2: new/delete vs malloc/free\n");
    printf(" malloc'd memory does not run a constructor:\n");
    Loud* raw = (Loud*)malloc(sizeof(Loud)); // allocates bytes, id is garbage
    printf("  raw->id happens to be: %d (uninitialized, do not rely on this)\n", raw->id);
    free(raw); // no destructor call either
    printf(" new/delete do both, automatically:\n");
    Loud* proper = new Loud(1);
    printf("  proper->id is: %d\n", proper->id);
    delete proper;
    printf("\n");

    // --- Part 3: new[] and delete[] have to match ---
    printf("Part 3: array new/delete must be paired with []\n");
    int* arr = new int[10];
    for (int i = 0; i < 10; ++i) arr[i] = i * i;
    printf("  arr[9] = %d\n", arr[9]);
    delete[] arr; // correct: matches new[]
    printf("  deleted with delete[], correctly paired\n\n");

#if DEMONSTRATE_MISMATCHED_DELETE
    printf("Part 3b: mismatched delete (no []) on an array allocation...\n");
    int* bad_arr = new int[10];
    delete bad_arr; // undefined behavior: only the first element's destructor
                     // logic runs, and for non-trivial types this corrupts
                     // the heap without necessarily crashing immediately
    printf("  if you see this line, it didn't crash THIS time -- that's the danger\n");
#endif

    // --- Part 4: host and device memory are separate heaps ---
    printf("Part 4: cudaMalloc/cudaFree is a different allocator entirely\n");
    int* device_ptr = nullptr;
    CUDA_CHECK(cudaMalloc(&device_ptr, 10 * sizeof(int)));
    printf("  device_ptr allocated via cudaMalloc: %p\n", (void*)device_ptr);
    CUDA_CHECK(cudaFree(device_ptr));
    printf("  freed via cudaFree -- matching allocator, as it must be\n\n");

#if DEMONSTRATE_HOST_FREE_ON_DEVICE_PTR
    printf("Part 4b: calling host free() on a cudaMalloc'd pointer...\n");
    int* bad_device_ptr = nullptr;
    CUDA_CHECK(cudaMalloc(&bad_device_ptr, 10 * sizeof(int)));
    free(bad_device_ptr); // undefined behavior: host allocator does not
                           // own this address, it belongs to the CUDA
                           // driver's allocator
    printf("  if you see this line, it didn't crash THIS time -- that's the danger\n");
#endif

    // --- Part 5: RAII -- ownership tied to scope, not manual bookkeeping ---
    printf("Part 5: RAII device buffer -- ownership tied to object lifetime\n");
    printf("  live DeviceBuffer objects before scope: %d\n", DeviceBuffer::live_count);
    {
        DeviceBuffer buf(1024);
        printf("  live DeviceBuffer objects inside scope: %d\n", DeviceBuffer::live_count);
    } // buf's destructor runs here, automatically, even without an explicit cudaFree
    printf("  live DeviceBuffer objects after scope: %d\n", DeviceBuffer::live_count);
    printf("  Verification: raii_cleanup_ran = %s\n",
           DeviceBuffer::live_count == 0 ? "PASS" : "FAIL");

    return (g_malloc_count == 0 && DeviceBuffer::live_count == 0) ? 0 : 1;
}
