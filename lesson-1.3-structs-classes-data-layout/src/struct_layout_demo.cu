// struct_layout_demo.cu
// Lesson 1.3 -- structs, classes, and data layout in memory. Field order
// changes struct size. This is not a compiler quirk, it's the alignment
// rules doing exactly what they're supposed to, and it's worth being
// able to predict rather than discover by accident.
//
// Still no kernel launch -- Module 1 scope. But this lesson's rules are
// the ones that decide how big an array of particles or points actually
// is once you start allocating thousands of them on the GPU in Module 6.
#include <cstdio>
#include <cstddef> // offsetof

// --- Part 1: fields declared in the order they occurred to someone,
// not the order that minimizes padding ---
struct NaiveParticle {
    char flag;    // 1 byte of data
    double mass;  // needs 8-byte alignment
    char active;  // 1 byte of data
    int id;       // needs 4-byte alignment
};

// --- Part 2: the same four fields, reordered largest-alignment-first ---
struct PackedParticle {
    double mass;  // 8-byte alignment, placed first
    int id;       // 4-byte alignment
    char flag;    // 1 byte
    char active;  // 1 byte
};

// --- Part 3: alignas forces a minimum alignment even when the natural
// alignment would already satisfy it, which matters once you care about
// SIMD-width or cache-line-width access later on ---
struct alignas(16) Vec4Aligned {
    float x, y, z, w;
};

// --- Part 4: compile-time verification ---
// These aren't runtime checks. If the assumed sizes below are wrong for
// the ABI this is compiled against, the file fails to compile -- there
// is no "run it and see" step for struct layout, because the layout is
// decided entirely at compile time.
static_assert(sizeof(NaiveParticle) == 24,
              "NaiveParticle layout assumption does not hold on this ABI");
static_assert(sizeof(PackedParticle) == 16,
              "PackedParticle layout assumption does not hold on this ABI");
static_assert(alignof(Vec4Aligned) == 16,
              "alignas(16) did not take effect as expected");

int main() {
    printf("Part 1: NaiveParticle -- fields in declaration order\n");
    printf("  sizeof(NaiveParticle) = %zu bytes\n", sizeof(NaiveParticle));
    printf("  offsetof flag   = %zu\n", offsetof(NaiveParticle, flag));
    printf("  offsetof mass   = %zu\n", offsetof(NaiveParticle, mass));
    printf("  offsetof active = %zu\n", offsetof(NaiveParticle, active));
    printf("  offsetof id     = %zu\n", offsetof(NaiveParticle, id));
    printf("  actual data: 1 + 8 + 1 + 4 = 14 bytes. padding: %zu bytes wasted.\n\n",
           sizeof(NaiveParticle) - 14);

    printf("Part 2: PackedParticle -- same fields, reordered\n");
    printf("  sizeof(PackedParticle) = %zu bytes\n", sizeof(PackedParticle));
    printf("  offsetof mass   = %zu\n", offsetof(PackedParticle, mass));
    printf("  offsetof id     = %zu\n", offsetof(PackedParticle, id));
    printf("  offsetof flag   = %zu\n", offsetof(PackedParticle, flag));
    printf("  offsetof active = %zu\n", offsetof(PackedParticle, active));
    printf("  actual data: 8 + 4 + 1 + 1 = 14 bytes. padding: %zu bytes wasted.\n\n",
           sizeof(PackedParticle) - 14);

    printf("Part 3: alignas(16) on a struct that would naturally be 16 anyway\n");
    printf("  sizeof(Vec4Aligned)  = %zu bytes\n", sizeof(Vec4Aligned));
    printf("  alignof(Vec4Aligned) = %zu bytes\n\n", alignof(Vec4Aligned));

    long saved_per_element = (long)sizeof(NaiveParticle) - (long)sizeof(PackedParticle);
    printf("Part 4: what reordering actually bought us\n");
    printf("  %ld bytes saved per element just from field order\n", saved_per_element);
    printf("  for an array of 1,000,000 particles: %.2f MB saved\n",
           (saved_per_element * 1000000.0) / (1024.0 * 1024.0));

    printf("\nVerification: the three static_assert checks above already ran\n");
    printf("  at compile time. this program would not exist as a binary\n");
    printf("  if any of them had failed. Verification: layout_assumptions = PASS\n");

    return 0;
}
