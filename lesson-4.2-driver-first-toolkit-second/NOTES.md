# Author notes -- lesson 4.2

- The single most important distinction in this lesson: nvidia-smi's
  "CUDA Version" field is driver capability headroom, NOT an installed
  toolkit version. This number appears even on a machine with no CUDA
  Toolkit installed at all. Keep this distinction explicit and
  unambiguous in any edit -- it is one of the most common sources of
  confusion for people new to CUDA, and conflating it with "the CUDA
  version I have" anywhere in this lesson's text would actively
  reinforce the exact misunderstanding this lesson exists to prevent.
- The parsing regex for both scripts assumes nvidia-smi's banner format
  contains a literal "CUDA Version: X.Y" substring, which has been
  stable across recent driver releases in testing. If NVIDIA changes
  this output format in a future driver release, both scripts' parsing
  will need updating -- worth a quick sanity check against the actual
  publish machine's nvidia-smi output before publishing.
- This lesson does not reproduce the exact wording of the runtime error
  a reader would see from installing the toolkit before the driver
  (e.g. an insufficient-driver-version error at CUDA runtime init). The
  lesson text references the general error category
  (cudaErrorInsufficientDriver) by name without claiming an exact
  message string, since exact wording can vary by CUDA version and
  platform -- keep this hedge if editing rather than inventing a
  specific quoted error message.
- No CMakeLists.txt or compiled source, consistent with lesson 4.1 --
  same reasoning: the toolkit isn't installed yet at this point in the
  sequence.
