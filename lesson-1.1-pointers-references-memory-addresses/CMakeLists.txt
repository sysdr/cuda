cmake_minimum_required(VERSION 3.28)
project(lesson_1_1_pointers LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_CUDA_ARCHITECTURES 86)

find_package(CUDAToolkit 13.3 REQUIRED)

add_executable(pointers_intro src/pointers_intro.cu)
target_link_libraries(pointers_intro PRIVATE CUDA::cudart)
