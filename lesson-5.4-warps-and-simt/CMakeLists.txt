cmake_minimum_required(VERSION 3.28)
project(lesson_5_4_warp_divergence LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_CUDA_ARCHITECTURES 86)

find_package(CUDAToolkit 13.3 REQUIRED)

add_executable(warp_divergence_demo src/warp_divergence_demo.cu)
target_link_libraries(warp_divergence_demo PRIVATE CUDA::cudart)
