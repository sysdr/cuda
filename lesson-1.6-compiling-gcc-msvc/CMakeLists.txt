cmake_minimum_required(VERSION 3.28)
project(lesson_1_6_compiler_handoff LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_CUDA_ARCHITECTURES 86)

find_package(CUDAToolkit 13.3 REQUIRED)

add_executable(compiler_handoff_demo src/compiler_handoff_demo.cu)
target_link_libraries(compiler_handoff_demo PRIVATE CUDA::cudart)

# MSVC's __cplusplus macro reports an old, fixed value (usually 199711L)
# unless this flag is passed explicitly -- a long-standing MSVC default
# kept for backward compatibility. Going through nvcc, the flag has to
# be forwarded to cl.exe with -Xcompiler, not passed to nvcc directly.
target_compile_options(compiler_handoff_demo PRIVATE
    $<$<AND:$<COMPILE_LANGUAGE:CUDA>,$<CXX_COMPILER_ID:MSVC>>:-Xcompiler=/Zc:__cplusplus>
)

# Host-side warnings, forwarded through nvcc the same way. /W3 on MSVC,
# -Wall on GCC -- same idea as every other lesson's CMakeLists in this
# course, called out explicitly here because this is the lesson about it.
target_compile_options(compiler_handoff_demo PRIVATE
    $<$<AND:$<COMPILE_LANGUAGE:CUDA>,$<CXX_COMPILER_ID:MSVC>>:-Xcompiler=/W3>
    $<$<AND:$<COMPILE_LANGUAGE:CUDA>,$<CXX_COMPILER_ID:GNU>>:-Xcompiler=-Wall>
)
