# Author notes -- lesson 1.6

- The /Zc:__cplusplus MSVC behavior is real, long-documented, and worth
  confirming still applies as described under CUDA 13.3 + the specific
  VS 2022 toolset version used at publish time -- Microsoft has been
  slowly changing the default in some newer toolset/SDK combinations.
  Verify __cplusplus's DEFAULT (i.e. with the /Zc:__cplusplus line in
  CMakeLists commented out) actually still under-reports before
  publishing the "on MSVC this usually means..." framing as confidently
  as the lesson text currently states it.
- On Ubuntu/WSL2 with GCC, __cplusplus reports correctly by default with
  no equivalent flag needed -- this asymmetry between platforms is
  itself worth keeping in the lesson text, since it's a real reason
  Windows-only CUDA projects sometimes carry silent C++14-era behavior
  without anyone noticing.
- No kernel launch, consistent with the rest of Module 1. This lesson is
  about the build pipeline itself rather than a runtime CUDA mechanism,
  which is why its "verification" doubles as a genuinely useful
  diagnostic rather than just a teaching device.
- The --verbose / -v suggestion in the README produces a lot of output.
  Consider capturing a trimmed real example (just the two top-level
  compiler invocations, not every intermediate step) for the lesson
  text rather than sending readers in blind.
