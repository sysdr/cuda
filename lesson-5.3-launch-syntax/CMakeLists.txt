cmake_minimum_required(VERSION 3.28)
project(lesson_5_3_launch_syntax LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_CUDA_ARCHITECTURES 86)

find_package(CUDAToolkit 13.3 REQUIRED)

add_executable(launch_syntax_demo src/launch_syntax_demo.cu)
target_link_libraries(launch_syntax_demo PRIVATE CUDA::cudart)
