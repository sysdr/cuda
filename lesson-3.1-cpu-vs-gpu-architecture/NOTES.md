# Author notes -- lesson 3.1

- The "RTX 3050" name covers genuinely different hardware configurations
  across desktop 8GB, desktop 6GB, and laptop variants -- SM counts and
  core counts differ between them. Do NOT hardcode an assumed CUDA core
  count for "the RTX 3050" anywhere in the published lesson text. Let
  the program query and print the real number for whatever card the
  reader actually has, and only describe the architecture-level facts
  (128 cores/SM on Ampere consumer parts, cc 8.6, 1536 threads/SM) as
  the stable, citable claims.
- The bandwidth formula (2 x memClockRate_kHz x busWidth/8 / 1e6) is the
  same one used in NVIDIA's own deviceQuery sample. It computes a
  THEORETICAL peak, not the achievable bandwidth number (~168 GB/s)
  used elsewhere in this course's material for the RTX 3050 6GB. The
  lesson text should keep this distinction explicit -- do not let the
  two numbers get conflated as if they're the same figure measured two
  ways.
- The cores_per_sm() table is deliberately incomplete. If a reader runs
  this on hardware not covered by the table (older than Pascal, or a
  newer architecture released after this course), it should print
  "unknown" rather than a wrong guess. Do not expand this table with
  guessed values -- only add entries you can verify against NVIDIA's
  own architecture documentation.
- The "typical desktop CPU" comparison numbers in Part 4 are
  deliberately vague (a range, "tens of MB") rather than a specific
  named CPU model, because naming a specific chip invites the reader to
  compare against stale or wrong numbers for their own machine. Keep
  this framing if the lesson text is edited later.
- No kernel launch, consistent with the rest of Phase 1 (Modules 1-4).
