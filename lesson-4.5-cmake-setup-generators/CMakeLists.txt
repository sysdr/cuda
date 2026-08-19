# CMakeLists.txt -- lesson 4.5
# Every field below has appeared, unexplained, in every CMakeLists.txt
# since lesson 7.5. This is the file where each line finally gets its
# explanation.

cmake_minimum_required(VERSION 3.28)
# The minimum CMake version this file requires. 3.28 is the version
# this course standardizes on -- new enough for solid first-class CUDA
# language support, old enough to be trivially installable everywhere.

project(lesson_4_5_cmake_demo LANGUAGES CXX CUDA)
# Declares the project and, critically, which LANGUAGES it uses.
# Listing CUDA here is what makes CMake treat .cu files as a distinct
# language with its own compiler (nvcc), rather than trying to hand
# them to a plain C++ compiler that wouldn't understand them.

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CUDA_STANDARD 17)
# The C++ standard for the host-code half of every .cu file, and
# separately for the device-code half. This course targets C++17 for
# both, consistently, since lesson 1.1.

set(CMAKE_CUDA_ARCHITECTURES 86)
# The compute capability to actually generate device code for -- 86
# for Ampere consumer cards (RTX 3050/3060/2050), this course's target
# throughout. Skipping this, or setting it wrong, is a common source of
# a kernel that compiles fine but fails at launch on the actual GPU.

find_package(CUDAToolkit 13.3 REQUIRED)
# Locates the CUDA Toolkit lesson 4.4 installed, and specifically
# requires version 13.3 or newer -- REQUIRED means CMake's configure
# step fails loudly here if the toolkit isn't found, rather than
# failing confusingly later during the actual build.

add_executable(cmake_build_demo src/cmake_build_demo.cu)
# Declares the actual binary to build and which source file(s) produce
# it. For a bigger project this is where every additional .cu or .cpp
# file would be listed.

target_link_libraries(cmake_build_demo PRIVATE CUDA::cudart)
# Links against the CUDA runtime library -- this is what makes
# cudaRuntimeGetVersion, cudaGetDeviceProperties, and every other CUDA
# runtime API call in this lesson's source file actually resolve at
# link time instead of producing an "undefined reference" error.
