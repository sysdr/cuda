cmake_minimum_required(VERSION 3.28)
project(lesson_3_2_threads_processes LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_CUDA_ARCHITECTURES 86)

find_package(CUDAToolkit 13.3 REQUIRED)

# This lesson is the first to use std::thread. On Linux/WSL, GCC needs
# an explicit pthread link -- CMake's Threads package handles this
# portably across GCC and MSVC rather than hardcoding -pthread.
set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)

add_executable(threads_processes_demo src/threads_processes_demo.cu)
target_link_libraries(threads_processes_demo PRIVATE CUDA::cudart Threads::Threads)
