# Author notes -- lesson 3.4

- The measured parallel fraction P is NOT hardcoded to 0.9 -- it's
  computed from an actual timed baseline (serial_work and parallel_work
  run separately at N=1). The lesson text's worked example using P=0.9
  and specific speedup numbers (1.82x, 3.08x, 4.71x at N=2/4/8) is
  illustrative, based on a representative run -- confirm the ACTUAL
  measured P on the publish machine falls reasonably close to 0.9
  before publishing those specific illustrative numbers, or adjust the
  worked-example numbers in the lesson text to match whatever P the
  publish machine actually produces. Do not present the illustrative
  numbers as guaranteed output.
- kSerialIterations and kParallelElements were tuned to produce roughly
  a 90/10 parallel/serial split on a representative development
  machine. Different CPU architectures (clock speed, SIMD support for
  sin/cos) may shift this ratio meaningfully. If the measured P comes
  out far from ~0.9 on the publish machine, that's fine and still
  demonstrates the lesson's point -- just update the illustrative
  numbers in the lesson text to match.
- The empirical_speedup_within_predicted_bound check uses a 15%
  tolerance (predicted * 1.15) rather than requiring empirical <=
  predicted exactly, because measurement noise can occasionally push
  the empirical figure very slightly above the naive Amdahl prediction
  even though Amdahl's formula is an idealized ceiling. If this check
  fails frequently on the publish machine, investigate before loosening
  the tolerance further -- a large or consistent overshoot would be a
  genuine surprise worth understanding, not just tolerating.
- parallel_chunk uses sin/cos specifically because they're real,
  non-trivial floating point work the compiler can't trivially
  optimize away or auto-vectorize into something misleadingly fast --
  keep this if editing the workload.
- No kernel launch, consistent with the rest of Phase 1.
