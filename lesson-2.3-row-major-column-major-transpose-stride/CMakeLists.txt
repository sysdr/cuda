cmake_minimum_required(VERSION 3.28)
project(lesson_2_3_layout_transpose_stride LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_CUDA_ARCHITECTURES 86)

find_package(CUDAToolkit 13.3 REQUIRED)

add_executable(layout_transpose_stride_demo src/layout_transpose_stride_demo.cu)
target_link_libraries(layout_transpose_stride_demo PRIVATE CUDA::cudart)
