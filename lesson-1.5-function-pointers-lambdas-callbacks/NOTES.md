# Author notes -- lesson 1.5

- Part 4 uses cudaLaunchHostFunc, not the older cudaStreamAddCallback.
  cudaStreamAddCallback has been effectively superseded since CUDA 10
  and cudaLaunchHostFunc is the currently recommended API -- if you see
  older CUDA material using cudaStreamAddCallback, that's the deprecated
  path, not an error in this lesson.
- No kernel launch anywhere in this file. cudaMemsetAsync and
  cudaLaunchHostFunc are both legitimate stream operations that never
  touch <<<...>>> syntax, which keeps this lesson inside Module 1's
  established scope while still landing a real, currently-used CUDA API.
- The commented-out line in Part 2 (`BinaryOp bad = capturing;`) is left
  in as a comment deliberately -- it's a compile error, not a runtime
  one, and the lesson text explains why. Do not uncomment it in the
  shipped code; if you want to demonstrate the actual compiler error
  for the written lesson, compile that one line in isolation separately
  and paste the real error message rather than guessing at its wording.
- The callback's print statement includes a claim worth verifying on
  the actual publish machine: that cudaLaunchHostFunc callbacks run on
  a CUDA-driver-managed host thread, not necessarily the thread that
  called cudaStreamSynchronize. This is documented NVIDIA behavior but
  the lesson text should not overstate which specific thread it is
  beyond "a thread the driver manages" unless independently confirmed
  against the CUDA 13.3 programming guide.
