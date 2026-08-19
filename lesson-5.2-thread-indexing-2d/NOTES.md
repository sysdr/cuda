# Author notes -- lesson 5.2

- width=64, height=64, block=(16,16) was chosen specifically so total
  thread count (4096), total blocks (16), and threads per block (256)
  all match lesson 5.1's numbers exactly -- same resources, reshaped
  from 1D into 2D. Keep this parallel; it's the core teaching device
  of this lesson (same total work, different organization).
- Part 5's callback to lesson 7.4/7.5's row/col indexing pattern is a
  direct, verifiable claim -- if either of those lessons' kernel code
  changes, check this lesson's printed comparison still matches
  exactly.
- The spot-check in Part 4 (row=37, col=22) is deliberately an
  arbitrary interior point, not a boundary -- boundaries are already
  covered by the out[63]/out[64] check in Part 3. This second check
  exists to confirm the formula works everywhere, not just at the
  seams.
- No 3D kernel in this lesson's code -- the lesson text covers the 3D
  extension analytically (the formula pattern) without a third
  kernel, since 2D is what nearly every practical kernel in this
  course actually needs, and a 3D demo would add code without adding
  a meaningfully new idea beyond "one more term, same pattern."
