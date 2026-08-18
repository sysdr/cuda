# Author notes -- lesson 4.3

- The Windows script's core technical point matters and should not get
  simplified away in editing: checking "is cl.exe on PATH" from a
  plain PowerShell/CMD session gives a FALSE NEGATIVE even on a
  correctly installed system, because cl.exe only enters PATH inside a
  Developer Command Prompt or after vcvars64.bat runs. vswhere.exe is
  the real, Microsoft-shipped, documented way to check without
  requiring the reader to open a Developer Prompt. Do not "simplify"
  this to a plain PATH check -- it would silently reintroduce the exact
  false-negative problem this lesson exists to avoid.
- vswhere.exe's fixed install path (C:\Program Files (x86)\Microsoft
  Visual Studio\Installer\vswhere.exe) has been stable across VS2022
  releases in testing. Worth a spot check against the actual publish
  machine before publishing, since Microsoft could in principle change
  installer layout in a future VS2022 update.
- The specific component ID checked
  (Microsoft.VisualStudio.Component.VC.Tools.x86.x64) is the correct,
  documented component ID for the C++ build tools as of current VS2022
  releases. If Microsoft renames or splits this component in a future
  release, the script's -requires flag would need updating.
- This lesson explicitly reassures the reader they never need to open
  the Visual Studio IDE itself -- keep this framing. It's a common
  point of confusion for people expecting a "create a new project"
  workflow, when this course's CMake-based builds never touch the IDE
  at all.
- No CMakeLists.txt or compiled CUDA source, consistent with lessons
  4.1 and 4.2 -- the toolkit isn't installed yet at this point.
