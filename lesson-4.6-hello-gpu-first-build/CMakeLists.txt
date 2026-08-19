cmake_minimum_required(VERSION 3.28)
project(lesson_4_6_hello_gpu LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_CUDA_ARCHITECTURES 86)

find_package(CUDAToolkit 13.3 REQUIRED)

add_executable(hello_gpu src/hello_gpu.cu)
target_link_libraries(hello_gpu PRIVATE CUDA::cudart)

# Every line above was explained in full in lesson 4.5 -- this file is
# the plain, unannotated version every lesson from here on will use.
