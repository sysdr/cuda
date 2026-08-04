# Author notes -- lesson 2.2

- No CUDA API calls anywhere in this file -- same precedent as 1.3 and
  2.1. common/cuda_check.cuh is copied into the zip for structural
  consistency with the rest of the course but is not included or used
  by this lesson's source.
- Part 2 and Part 3's verification values (19, 22, 43, 50) are exact
  and hand-checkable -- no <!-- MEASURED --> placeholders needed for
  those. Part 4's timing and GFLOP/s numbers are hardware-dependent and
  DO need a real run on the publish machine before filling in
  expected_output.txt.
- matmul_via_dot_n in Part 3 is intentionally the slow, allocation-heavy
  way to compute the same result -- it builds a new std::vector for
  every row and column extraction. This is a deliberate teaching choice
  to make the lesson 2.1 connection concrete in code, not a
  recommendation for how to actually write this. Say so explicitly in
  the lesson text if it isn't already clear enough.
- Default N=256 keeps Part 4's runtime under a second on most modern
  CPUs in Release mode. If the publish machine is unusually slow,
  consider lowering the default rather than leaving readers with a
  multi-second first-run experience.
