# Author notes -- lesson 3.3

- Part 1 deliberately triggers undefined behavior per the C++ standard:
  a data race on a non-atomic int with no synchronization. On every
  real system tested this reliably manifests as lost updates (a final
  count lower than expected) rather than a crash -- that reliability is
  itself worth stating plainly in the lesson text, but "reliably" is
  doing real work in that sentence and should not be oversold as a
  language guarantee. In principle a sufficiently aggressive optimizer
  could do something even less intuitive (e.g. cache race_counter in a
  register for the whole loop, since it's legally allowed to assume no
  other thread modifies it). If a Release build ever shows a count of
  EXACTLY kIncrementsPerThread (i.e., as if only one thread's writes
  survived at all), that is a more severe manifestation of the same UB,
  not a different bug -- worth a footnote in the published lesson if it
  happens on the publish machine.
- race_ever_wrong is very likely true on any real run given 8 threads x
  500,000 increments, but is not a mathematical certainty -- it is
  observed behavior on real hardware, not a guarantee. Do not claim in
  the lesson text that the race is guaranteed to reproduce every single
  time; claim that it reliably does in practice, which is both true and
  honest.
- The PASS/FAIL semantics in Part 1 are intentionally inverted from
  every other lesson in this course -- PASS here means "we successfully
  observed the bug," not "the code is correct." This is called out
  explicitly in both the program's own output and the lesson text. Do
  not let this framing get lost if the lesson is edited later; it's a
  real point of potential confusion worth over-explaining rather than
  under-explaining.
- Part 4's callback to lesson 7.5's actual __syncthreads() usage should
  be checked against that lesson's current source if 7.5 is ever
  revised -- the claim here about "twice per tile iteration" needs to
  stay accurate to the real code.
- First lesson to suggest a sanitizer build (ThreadSanitizer) as an
  optional side exercise, outside the normal CMake flow. This is
  intentional and should stay clearly marked as a separate,
  non-standard build in the README, not folded into the main
  CMakeLists.txt.
