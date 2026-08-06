# Author notes -- lesson 3.2

- First lesson using std::thread. CMakeLists.txt now finds and links
  Threads::Threads in addition to CUDA::cudart -- this is required on
  Linux/WSL where GCC needs explicit pthread linkage, and is harmless
  on Windows where MSVC doesn't need it. Do not drop this from future
  lessons that also use std::thread.
- Part 2's per-thread timing number is a real measurement and WILL vary
  significantly across machines -- OS, thread library implementation,
  and system load all affect it meaningfully more than most timing
  numbers elsewhere in this course. Expect single-digit to low-double-digit
  microseconds per thread on a typical desktop, but actually measure on
  the publish machine rather than assuming a specific figure.
- The claim in Part 3 that GPU threads involve "no separate stack
  allocation, no scheduler negotiation, no kernel-level bookkeeping per
  thread" is accurate at a conceptual level but deliberately not backed
  by a citation to a specific NVIDIA architecture document in this
  lesson's text -- it's presented as the conceptual contrast this
  lesson sets up, with the real mechanism (warps, SIMT execution)
  properly built out starting in Module 5. Do not let this lesson's
  text overreach into claiming specifics about warp scheduling that
  belong to lesson 5.1 and 5.4.
- No kernel launch, consistent with the rest of Phase 1. This is the
  last lesson in the course that can make this claim so directly --
  Module 5 begins actually building what's only described here.
