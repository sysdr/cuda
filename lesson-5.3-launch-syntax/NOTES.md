# Author notes -- lesson 5.3

- Part 2's reverse_block_dynamic is chosen specifically because dynamic
  shared memory syntax (extern __shared__ with no compile-time size,
  sized instead by the launch's third argument) is easy to get wrong
  and easy to under-explain. The reversal gives a genuinely checkable,
  non-trivial reason to use shared memory here, without requiring
  Module 6's full memory-hierarchy theory -- this lesson stays scoped
  to launch syntax mechanics, not shared memory performance.
- Part 3's stream demo is deliberately minimal -- it only proves the
  fourth launch argument works mechanically (launch succeeds, result
  is correct, using cudaStreamSynchronize instead of
  cudaDeviceSynchronize). It explicitly does NOT attempt to demonstrate
  the actual benefit of streams (overlapping transfer and compute) --
  that requires multiple concurrent streams and asynchronous memcpy,
  which is Module 8's dedicated subject. Keep this scope boundary
  explicit in the lesson text; do not let this lesson's stream example
  expand into async-overlap territory.
- shared_bytes is computed as exactly block_size * sizeof(int) -- no
  more, no less. This is worth keeping precise in any edit: requesting
  MORE dynamic shared memory than a kernel actually indexes into is a
  silent waste, not an error, and requesting LESS than the kernel reads
  or writes is undefined behavior. Getting this number exactly right is
  the entire point of the third launch argument existing.
- The reversal is per-block, not global -- block 1's chunk reverses
  within itself (256..511 reversing to 511..256), not against the
  whole 1024-element array. The Part 2 verification output calls this
  out explicitly (block 1: expected 511, 256) specifically to prevent
  a reader from assuming a global reversal was intended.
