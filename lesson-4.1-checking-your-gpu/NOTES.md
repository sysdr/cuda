# Author notes -- lesson 4.1

- This is the first lesson in the course without a CMakeLists.txt or
  any compiled source. That's intentional -- the entire premise of
  Module 4's early lessons is "before you have a toolchain at all."
  Do not force a CUDA build into this lesson just for consistency with
  earlier modules; it would be dishonest about what's actually
  available to the reader at this point in the setup sequence.
- The GPU name -> compute capability lookup table in both scripts is
  deliberately small and explicitly incomplete, same philosophy as the
  cores_per_sm() tables in lessons 3.1 and 3.5. A card that isn't in
  the table prints UNKNOWN and points to NVIDIA's own page, rather than
  guessing. Do not expand this table with unverified entries.
- The driver version check (>= 580 for CUDA 13.3) assumes the reader is
  targeting CUDA 13.3 Update 1 as established throughout this course.
  If the course's target CUDA version changes, this threshold needs
  updating in both scripts.
- nvidia-smi's driver_version field format can vary slightly across
  platforms (e.g., trailing sub-version numbers). The parsing here
  takes only the first dot-separated component as the "major" driver
  version, which has been reliable in testing but should be spot
  checked against the actual nvidia-smi output format on the publish
  machine before publishing the lesson's expected_output.txt.
- Both scripts are read-only and side-effect-free -- they only query,
  never install or modify anything. Worth stating this reassurance
  explicitly in the lesson text, since a reader running their first
  script from a tutorial is reasonably cautious about what it might do.
