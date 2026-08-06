cmake_minimum_required(VERSION 3.28)
project(lesson_3_1_cpu_vs_gpu_architecture LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_CUDA_ARCHITECTURES 86)

find_package(CUDAToolkit 13.3 REQUIRED)

add_executable(cpu_vs_gpu_architecture_demo src/cpu_vs_gpu_architecture_demo.cu)
target_link_libraries(cpu_vs_gpu_architecture_demo PRIVATE CUDA::cudart)
