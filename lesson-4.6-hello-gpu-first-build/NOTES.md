# Author notes -- lesson 4.6

- This is the last lesson in the course with no __global__ function
  and no kernel launch. The absence is deliberate and the lesson text
  says so explicitly rather than leaving the reader to wonder why a
  file named "hello_gpu.cu" doesn't do the thing every other CUDA
  "hello world" tutorial does. Do not add a kernel here to "satisfy"
  the filename -- that would undercut the anticipation this course has
  built since lesson 3.5's closing line, and it would upstage Module
  5's actual first-kernel moment, which the curriculum structures
  around lessons 5.1-5.3 specifically (execution model concepts before
  the launch syntax itself).
- This lesson's program is intentionally a "greatest hits" consolidation
  of every check from lessons 4.1 (device/driver), 4.2 (driver
  headroom), 3.1-style device properties, and 4.4 (toolkit/runtime
  version) -- built via CMake per lesson 4.5. It is meant to feel like
  a capstone for the whole Module 1-4 setup journey, not a new topic.
- The CMakeLists.txt here is deliberately UNANNOTATED, in contrast to
  lesson 4.5's heavily-commented version -- the reasoning being that
  4.5 already explained every line, and this file demonstrates the
  "normal," lived-in version every lesson from Module 5 onward will
  actually use. Keep this contrast if editing either file.
- warp_size_is_32 is included in the final checklist as a callback to
  lesson 3.1's first-ever hardware verification claim -- full circle
  from the first architectural fact this course checked to the last
  lesson before kernels exist.
