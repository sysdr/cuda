// callbacks_demo.cu
// Lesson 1.5 -- function pointers, lambdas, and callbacks. The Module 1
// closer: this is the lesson where the C++ groundwork stops being
// groundwork and turns into a real CUDA mechanism you'll use starting
// in Module 8. cudaLaunchHostFunc is a genuine callback API -- no
// kernel launch involved, which keeps this inside Module 1's scope,
// but it's the first CUDA API in this course that only makes sense
// once you understand what a function pointer actually is.
#include <cstdio>
#include <atomic>
#include <functional>
#include "../common/cuda_check.cuh"

// --- Part 1: a plain C-style function pointer ---
int add(int a, int b) { return a + b; }
int multiply(int a, int b) { return a * b; }

using BinaryOp = int (*)(int, int); // a function pointer type

int apply(BinaryOp op, int a, int b) {
    return op(a, b); // calling through the pointer, no idea at compile
                      // time which function this actually is
}

// --- Part 3: a callback parameter, generic enough to accept a function
// pointer, a non-capturing lambda, or a capturing lambda via templates ---
template <typename Callback>
int run_with_callback(int input, Callback&& cb) {
    int result = input * 2;
    cb(result); // invoke whatever was passed in
    return result;
}

// --- Part 4: the shape cudaLaunchHostFunc actually requires ---
// This has to be a plain function pointer matching cudaHostFn_t exactly:
// void (*)(void*). A capturing lambda cannot convert to this type --
// there's no slot in the function pointer for the captured state to
// live in. Context has to travel through the void* userData parameter
// instead, which is the C-style answer to the same problem a capturing
// lambda solves at the language level.
struct CallbackContext {
    std::atomic<bool> callback_ran{false};
    int value_seen_by_callback = 0;
};

void CUDART_CB host_callback(void* user_data) {
    auto* ctx = static_cast<CallbackContext*>(user_data);
    ctx->value_seen_by_callback = 42;
    ctx->callback_ran.store(true);
    printf("  [host_callback running] stream work finished, this runs on a CUDA-managed thread\n");
}

int main() {
    // --- Part 1: dispatching through a function pointer ---
    printf("Part 1: function pointer dispatch\n");
    BinaryOp op = add;
    printf("  op = add,      apply(op, 3, 4) = %d\n", apply(op, 3, 4));
    op = multiply;
    printf("  op = multiply, apply(op, 3, 4) = %d\n\n", apply(op, 3, 4));

    // --- Part 2: lambdas -- capturing vs non-capturing ---
    printf("Part 2: lambdas and function pointer convertibility\n");
    auto non_capturing = [](int a, int b) { return a - b; };
    BinaryOp as_fn_ptr = non_capturing; // legal: no captured state to lose
    printf("  non-capturing lambda converted to BinaryOp: apply = %d\n", apply(as_fn_ptr, 10, 3));

    int offset = 100;
    auto capturing = [offset](int a, int b) { return a + b + offset; };
    // BinaryOp bad = capturing;  // would not compile -- see NOTES.md
    printf("  capturing lambda (offset=%d) called directly: %d\n", offset, capturing(3, 4));
    printf("  capturing lambdas cannot become a plain BinaryOp -- no place for 'offset' to live\n\n");

    // --- Part 3: a generic callback parameter ---
    printf("Part 3: passing different callable kinds to the same function\n");
    run_with_callback(21, [](int result) {
        printf("  non-capturing lambda callback saw result = %d\n", result);
    });
    int multiplier = 3;
    run_with_callback(21, [multiplier](int result) {
        printf("  capturing lambda callback saw result = %d (multiplier was %d)\n", result, multiplier);
    });
    printf("\n");

    // --- Part 4: cudaLaunchHostFunc -- a real CUDA callback, no kernel ---
    printf("Part 4: cudaLaunchHostFunc -- host callback tied to stream completion\n");
    cudaStream_t stream;
    CUDA_CHECK(cudaStreamCreate(&stream));

    int* device_buf = nullptr;
    CUDA_CHECK(cudaMalloc(&device_buf, 1024 * sizeof(int)));
    CUDA_CHECK(cudaMemsetAsync(device_buf, 0, 1024 * sizeof(int), stream));

    CallbackContext ctx;
    CUDA_CHECK(cudaLaunchHostFunc(stream, host_callback, &ctx));

    printf("  work queued on the stream, callback_ran = %s (before sync)\n",
           ctx.callback_ran.load() ? "true" : "false");
    CUDA_CHECK(cudaStreamSynchronize(stream));
    printf("  after cudaStreamSynchronize, callback_ran = %s\n",
           ctx.callback_ran.load() ? "true" : "false");
    printf("  Verification: host_callback_executed = %s\n",
           ctx.callback_ran.load() && ctx.value_seen_by_callback == 42 ? "PASS" : "FAIL");

    CUDA_CHECK(cudaFree(device_buf));
    CUDA_CHECK(cudaStreamDestroy(stream));

    return (ctx.callback_ran.load() && ctx.value_seen_by_callback == 42) ? 0 : 1;
}
