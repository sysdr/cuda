# Author notes -- lesson 1.2

- Both DEMONSTRATE_* macros are off by default and both are genuine UB.
  DEMONSTRATE_MISMATCHED_DELETE is the milder of the two -- on a trivial
  type like int it often does not crash at all, which is itself the
  point worth making in the lesson text: UB that doesn't crash is more
  dangerous than UB that does, because nothing forces you to notice it.
- DEMONSTRATE_HOST_FREE_ON_DEVICE_PTR reliably crashes on every
  Linux/WSL setup tested (glibc's free() reads a header just before the
  pointer that isn't there for a cudaMalloc'd address). Still worth
  testing on the actual publish machine before claiming "reliably" in
  the lesson text -- glibc version differences could change this.
- The Loud struct's malloc'd-but-never-constructed instance reads
  raw->id as uninitialized memory. This is technically also UB (reading
  an uninitialized value is fine for a plain int in practice on most
  compilers, but relying on it is still wrong). The lesson text already
  says "do not rely on this" -- keep that caveat if you edit the copy.
- No kernel launch in this lesson either. Still Module 1 territory.
