# Author notes -- lesson 3.5

- cores_per_sm() is duplicated from lesson 3.1 rather than shared --
  same self-contained-zip precedent as every other lesson in this
  course. If lesson 3.1's table is ever corrected or extended, update
  this copy too.
- Peak FLOPS assumes 2 FLOPs/cycle/core (one FMA = one multiply + one
  add, counted as 2 operations). This is the standard, widely-used
  assumption for this kind of back-of-envelope peak calculation, but it
  IS a simplification -- real achieved FLOPS depend heavily on
  instruction mix, occupancy, and whether the workload can actually
  saturate FMA throughput. The lesson text should keep this caveat
  explicit rather than presenting "peak GFLOP/s" as an achievable
  number in practice, consistent with how lesson 3.1 already treats
  "theoretical peak bandwidth" as distinct from achieved bandwidth.
- The matmul arithmetic intensity formula (N/6) assumes the theoretical
  best case where every input byte is read exactly once. lesson 2.2's
  actual naive triple loop does NOT achieve this -- it re-reads B's
  columns N times over, which is the entire subject of lesson 2.3's
  transpose lesson and lesson 7.5's tiling lesson. Make sure the lesson
  text is clear that N/6 is a ceiling on AI (best case with perfect
  reuse), not what the naive loop from 2.2 actually achieves without
  tiling. This distinction matters and should not get flattened in
  editing.
- Verification thresholds for vecadd_ai and saxpy_ai are hardcoded
  numeric ranges (these are exact, deterministic arithmetic: 1/12 and
  2/12) -- safe to leave as fixed bounds, not <!-- MEASURED -->.
  classification_correct depends on the reader's actual ridge point, so
  its truth value depends on real hardware, but the classification
  PATTERN (small matmul memory-bound, large matmul compute-bound,
  vector ops always memory-bound) should hold on any GPU in the
  architecture table.
- No kernel launch. This is the last lesson in Phase 1 that can say
  that -- Module 5 begins actually launching kernels immediately after.
