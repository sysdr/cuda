cmake_minimum_required(VERSION 3.28)
project(lesson_1_3_struct_layout LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_CUDA_ARCHITECTURES 86)

find_package(CUDAToolkit 13.3 REQUIRED)

add_executable(struct_layout_demo src/struct_layout_demo.cu)
target_link_libraries(struct_layout_demo PRIVATE CUDA::cudart)
