# Author notes -- lesson 4.4

- This lesson deliberately compiles with a raw nvcc invocation, no
  CMakeLists.txt -- CMake setup belongs to lesson 4.5. Do not
  anticipate 4.5's content here.
- No __global__ kernel and no <<<...>>> launch anywhere in this file --
  same Phase-1 scoping precedent as every lesson since 1.1. This file
  proves the toolkit works using only host-side CUDA runtime API calls
  (cudaRuntimeGetVersion, cudaDriverGetVersion, cudaGetDeviceProperties),
  the same category lesson 3.1 already established as acceptable
  without teaching kernel launch syntax early. The actual "first
  kernel" moment stays reserved for later, consistent with how this
  course has built anticipation toward Module 5 since lesson 3.5's
  closing line.
- The three-numbers framing is the core teaching point and should not
  get flattened: (1) nvidia-smi's CUDA Version = driver headroom,
  covered in lesson 4.2; (2) what nvcc compiled the runtime API headers
  against, read via cudaRuntimeGetVersion(); (3) what the driver
  actually supports at runtime, read via cudaDriverGetVersion(). On a
  clean single-toolkit install these should all agree. On a machine
  with multiple CUDA toolkits installed, they can genuinely diverge --
  a real, useful diagnostic case worth keeping in the lesson text.
- CUDA_KEYRING package version and Ubuntu release codename in the apt
  install commands (cuda-keyring_1.1-1_all.deb, ubuntu2204) should be
  verified against NVIDIA's current install instructions before
  publishing -- these specific package/version strings are the kind of
  detail NVIDIA updates between releases and the ones most likely to
  silently go stale in this lesson.
- toolkit_is_13_3 will read FAIL on any toolkit version other than
  exactly 13.3.x -- intentional, since this course targets that
  specific version throughout. Note this clearly if a reader has a
  newer or older toolkit installed for other reasons.
