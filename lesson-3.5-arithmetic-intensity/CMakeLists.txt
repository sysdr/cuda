cmake_minimum_required(VERSION 3.28)
project(lesson_3_5_arithmetic_intensity LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_CUDA_ARCHITECTURES 86)

find_package(CUDAToolkit 13.3 REQUIRED)

add_executable(arithmetic_intensity_demo src/arithmetic_intensity_demo.cu)
target_link_libraries(arithmetic_intensity_demo PRIVATE CUDA::cudart)
