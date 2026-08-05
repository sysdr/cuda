cmake_minimum_required(VERSION 3.28)
project(lesson_2_4_broadcast_reduction LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_CUDA_ARCHITECTURES 86)

find_package(CUDAToolkit 13.3 REQUIRED)

add_executable(broadcast_reduction_demo src/broadcast_reduction_demo.cu)
target_link_libraries(broadcast_reduction_demo PRIVATE CUDA::cudart)
