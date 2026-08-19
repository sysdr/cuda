# Author notes -- lesson 5.1

- This is the first lesson in the entire course with a __global__
  function and a <<<...>>> launch. Twenty-four prior lessons
  deliberately avoided this -- see NOTES.md in every Module 1-4 lesson.
  This is the payoff. Do not undersell it in the lesson text.
- write_thread_index() is chosen deliberately over vector_add or
  anything arithmetic -- the POINT of this specific lesson is making
  the hierarchy itself visible and checkable, not demonstrating useful
  computation. out[i] == i for every i is about as strong a
  verification as a kernel can offer: any indexing mistake anywhere
  shows up immediately and specifically (wrong value at a wrong
  index), not just as a vaguely wrong final answer.
- The cudaGetLastError() vs cudaDeviceSynchronize() distinction is
  introduced properly here for the first time, even though the
  CUDA_CHECK macro itself has existed since lesson 1.1. Keep this
  explanation intact -- it's the first time this course explains why
  BOTH checks are necessary around an actual kernel launch (launch
  config errors vs runtime execution errors), and it matters for every
  kernel from this point forward.
- out[255] and out[256] are called out specifically in the verification
  output because they're the boundary between block 0 and block 1 --
  seeing 255 then 256 in sequence is direct, concrete evidence the
  block boundary didn't introduce a gap or overlap in the indexing.
- block_size=256 and n=4096 were chosen so grid_size divides evenly
  (16 blocks exactly) -- there are deliberately zero "wasted" boundary
  threads in this specific configuration, which keeps the lesson's
  main example clean. The "what to try next" section is where an
  uneven N gets explored instead, so the boundary guard's actual
  necessity gets demonstrated there rather than cluttering the primary
  example.
