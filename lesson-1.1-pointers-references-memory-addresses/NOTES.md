# Author notes -- lesson 1.1

- The `host_query` branch matters: on some driver/toolkit combinations,
  `cudaPointerGetAttributes` on a plain stack pointer returns
  `cudaErrorInvalidValue` rather than populating `type` with 0. Both
  behaviors have been observed across CUDA 12.x and 13.x point releases.
  The lesson text treats the error itself as the teaching point rather
  than asserting one specific behavior -- verify which one your toolkit
  actually does and adjust the printed explanation if needed before
  publishing.
- `DEMONSTRATE_INVALID_HOST_DEREF` is off by default. If you flip it on
  to capture a real crash log for the lesson text, do it in a throwaway
  terminal -- it is genuinely undefined behavior and while it reliably
  segfaults on every Linux/WSL setup tested, "reliably" is not the same
  as "guaranteed."
- No kernel launch appears in this lesson on purpose. `<<<...>>>` syntax
  is introduced in Module 5. Keep it out of Module 1 lessons even where
  it would be easy to sneak in as a teaser.
