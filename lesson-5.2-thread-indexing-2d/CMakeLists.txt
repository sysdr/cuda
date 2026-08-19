cmake_minimum_required(VERSION 3.28)
project(lesson_5_2_thread_hierarchy_2d LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_CUDA_ARCHITECTURES 86)

find_package(CUDAToolkit 13.3 REQUIRED)

add_executable(thread_hierarchy_2d_demo src/thread_hierarchy_2d_demo.cu)
target_link_libraries(thread_hierarchy_2d_demo PRIVATE CUDA::cudart)
