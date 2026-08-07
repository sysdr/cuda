cmake_minimum_required(VERSION 3.28)
project(lesson_3_4_amdahls_law LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_CUDA_ARCHITECTURES 86)

find_package(CUDAToolkit 13.3 REQUIRED)

set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)

add_executable(amdahls_law_demo src/amdahls_law_demo.cu)
target_link_libraries(amdahls_law_demo PRIVATE CUDA::cudart Threads::Threads)
