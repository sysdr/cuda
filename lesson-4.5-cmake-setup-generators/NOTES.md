# Author notes -- lesson 4.5

- cmake_build_demo.cu is deliberately identical in content to lesson
  4.4's toolkit_smoke_test.cu. This is intentional and should stay
  that way -- the lesson's entire point is isolating the build-system
  change as the only variable. Do not add new C++ content here; any
  new material belongs in the CMakeLists.txt annotations instead.
- The default apt cmake package being older than 3.28 on several
  common Ubuntu releases is a real, current problem worth keeping in
  the lesson text -- verify the specific version gap against the
  actual Ubuntu release used on the publish machine before stating a
  specific old version number, and prefer the general framing ("often
  older than 3.28") over a precise claimed number that could go stale.
- No kernel launch, no __global__ function -- same Phase-1 precedent
  as every lesson since 1.1.
- The CMakeLists.txt comments in this lesson are written to be read as
  the primary teaching content for this lesson's "what does each line
  do" material -- if the lesson markdown is edited, keep the comments
  in the actual CMakeLists.txt file synchronized with whatever
  explanation appears in the prose, since future lessons' CMakeLists.txt
  files reference this one as "already explained in 4.5."
