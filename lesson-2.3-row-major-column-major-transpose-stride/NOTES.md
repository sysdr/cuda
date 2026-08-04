# Author notes -- lesson 2.3

- No CUDA API calls in this file -- same precedent as 1.3, 2.1, 2.2.
- Parts 1-4 are exact and deterministic -- no <!-- MEASURED -->
  placeholders needed. Part 5's timing numbers are hardware- and
  cache-dependent and need a real Release-mode run on the publish
  machine before expected_output.txt is finalized.
- The speedup in Part 5 depends heavily on N relative to cache size,
  same caveat as lesson 1.4's AoS/SoA benchmark. At N=256 (256KB per
  matrix) this may already fit inside a modern desktop CPU's L2/L3
  cache, which will understate the effect compared to a larger N. If
  the measured speedup at the default N is unconvincingly small,
  consider raising the default or noting the cache-fit caveat more
  prominently in the lesson text.
- This lesson deliberately answers lesson 2.2's "what to try next"
  exercise about transposing B. If 2.2's exercise wording ever changes,
  check this lesson's Part 6 framing still lines up with it.
- matmul_transposed_B still pays an O(N^2) transpose cost up front,
  which is NOT included in its timed section in this version of the
  code -- the lesson text should be honest that the benchmark isolates
  the inner-loop access pattern benefit and does not charge the
  transpose cost against it. This is a legitimate thing to flag as a
  limitation in the lesson text itself, not just here.
