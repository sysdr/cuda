# Author notes -- lesson 2.4

- No CUDA API calls in this file -- same precedent as 1.3, 2.1, 2.2, 2.3.
- Part 5 is the one part of this lesson worth double-checking on the
  actual publish machine. Floating point addition is not associative,
  so forward/reverse/tree summation orders CAN in principle diverge by
  more than the 1e-5 tolerance used here, especially for larger or
  more numerically adversarial inputs. The 8-value example was chosen
  specifically because it's small and well-behaved enough that all
  three orderings should agree comfortably within tolerance on any
  IEEE 754 double/float implementation -- but "should" is doing some
  work in that sentence. Actually run it before publishing rather than
  assuming.
- This lesson deliberately does NOT try to demonstrate a case where
  summation order produces a visibly different answer -- that would be
  a more advanced (and more numerically interesting) lesson than what
  Module 2 is scoped for. The point here is narrower: order CAN matter
  in principle, which is exactly why a tree-based parallel reduction
  (lesson 7.6) doesn't produce bit-identical results to a sequential
  sum, even though both are "correct."
- dot_n and reduce_sum are both redefined locally in this file rather
  than imported from lesson 2.1's or 2.2's zip -- every lesson's zip in
  this course is self-contained by design, so some small duplication
  across lessons is expected and fine.
