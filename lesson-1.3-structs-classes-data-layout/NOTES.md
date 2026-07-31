# Author notes -- lesson 1.3

- The static_assert sizes (24 for NaiveParticle, 16 for PackedParticle,
  16 for alignof(Vec4Aligned)) assume the standard x86-64 layout rules
  used by GCC, Clang, and MSVC on x86-64 -- which is what every
  supported build target in this course actually is (Ubuntu, WSL2,
  Windows native, all x86-64). These are not hardware-timing numbers
  that vary run to run; struct layout is deterministic for a given ABI,
  so these should hold on every machine a reader actually builds on.
  Still worth a real build before publishing -- if a reader's toolchain
  ever produces different numbers here, that's a genuinely interesting
  edge case worth investigating, not just a placeholder to fill in.
- If you extend this lesson to ARM (e.g., a reader on Apple Silicon
  cross-compiling, or Jetson), these exact byte counts are not
  guaranteed to hold. That's out of scope for this course's target
  hardware but worth a footnote if the audience ever asks.
- No kernel launch, consistent with the rest of Module 1. The payoff
  for this lesson's rules shows up concretely once arrays of these
  structs get allocated on the device starting in Module 6.
