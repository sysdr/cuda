# Author notes -- lesson 5.4

- The core empirical claim of this lesson -- divergent_work measurably
  slower than non_divergent_work despite identical iteration counts
  per thread -- MUST be verified on the actual publish machine before
  shipping. The 1.2x threshold in divergence_cost_visible is a
  deliberately loose bound to avoid false negatives from measurement
  noise, not a claimed real-world ratio. Do not state a specific
  expected speedup multiplier (like "divergence is always ~2x slower")
  in the lesson text -- the actual ratio depends on compiler
  optimization, instruction mix, and hardware, and can vary
  considerably. Report what was actually measured, hedge appropriately.
- The two branches in divergent_work deliberately use different
  constants (1.0001f/0.0001f vs 1.0002f/0.0002f) specifically so the
  compiler cannot legally merge or predicate away the branch into
  something equivalent to the non-divergent version. If a future
  compiler becomes aggressive enough to do so anyway despite the
  differing constants, the measured timing gap could shrink or
  disappear -- worth a real compile/run check, not just trusting this
  reasoning holds forever.
- kIterations=200 and kN=1<<20 were chosen to make the timing
  difference large enough to be visible above launch overhead and
  measurement noise, without making the whole program take
  unreasonably long to run. Adjust if the publish machine's timing
  shows the effect is too small to be convincing or the runtime is
  uncomfortably long.
- This lesson explicitly frames warp divergence as a preview, not the
  full optimization treatment -- that's lesson 10.2's job. Do not
  expand this lesson's scope into general divergence-avoidance
  techniques; stick to proving the mechanism exists and costs
  something real.
