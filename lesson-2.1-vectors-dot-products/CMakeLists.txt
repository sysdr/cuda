cmake_minimum_required(VERSION 3.28)
project(lesson_2_1_vectors_dot_product LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_CUDA_ARCHITECTURES 86)

find_package(CUDAToolkit 13.3 REQUIRED)

add_executable(vectors_dot_product_demo src/vectors_dot_product_demo.cu)
target_link_libraries(vectors_dot_product_demo PRIVATE CUDA::cudart)
