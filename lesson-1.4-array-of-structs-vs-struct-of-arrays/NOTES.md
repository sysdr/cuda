# Author notes -- lesson 1.4

- The CPU timing numbers depend heavily on cache size, which varies a
  lot across machines. Run this on the actual publish machine in
  Release mode before filling in the <!-- MEASURED --> placeholders --
  the speedup ratio is real but the exact multiplier will differ from
  whatever ends up in a draft. Expect somewhere in the 1.3x-3x range on
  a typical desktop CPU for this access pattern and N, but don't quote
  that range in the published lesson without actually measuring it.
- Part 5 allocates but never launches a kernel or copies data to the
  device -- this is intentional, matching the no-kernel-launch scoping
  used across the rest of Module 1. Do not add a kernel launch here
  even though it would be easy to; that content belongs to Module 6/7,
  and lesson 7.x already covers the GPU-side coalescing payoff this
  lesson sets up.
- Particle's 7 same-type float fields have no padding, which is a
  deliberate callback to lesson 1.3 -- worth keeping that contrast
  explicit in the text (this struct has zero padding, and the layout
  problem here is a completely different one from 1.3's).
- Debug builds will likely show little to no AoS/SoA difference because
  the compiler won't auto-vectorize the SoA loop without optimization.
  The README already warns about this; don't remove that warning.
