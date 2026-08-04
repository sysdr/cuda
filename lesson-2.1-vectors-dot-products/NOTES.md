# Author notes -- lesson 2.1

- No kernel launch, no cudaMalloc, no device code at all in this
  lesson -- same precedent as 1.3 (struct layout). The topic is pure
  math and CPU implementation, and cuda_check.cuh is included only for
  build consistency with the rest of the course's CMakeLists pattern,
  not because anything in this file needs it. Do not force in a
  cudaMalloc call just for the sake of "using" CUDA in this file.
- All verification values here are deterministic and hand-checkable
  (32.0f for the {1,2,3} . {4,5,6} example, 0 for perpendicular
  vectors, 25 for the 3-4-5 triangle's magnitude squared) -- unlike
  timing-based lessons, expected_output.txt needs no <!-- MEASURED -->
  placeholders. Every number in it should match exactly, every run,
  every machine.
- Part 4's callback to lesson 7.5 is intentional and should stay
  accurate -- if lesson 7.5's kernel or variable names ever change,
  update this reference to match.
- This is the first lesson built against the new white-background,
  hand-drawn diagram style. Diagrams 1.1 through 1.6 and 7.5 still use
  the old dark-theme spec and have not been retrofitted.
