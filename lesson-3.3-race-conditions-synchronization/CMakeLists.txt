cmake_minimum_required(VERSION 3.28)
project(lesson_3_3_race_conditions LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_CUDA_ARCHITECTURES 86)

find_package(CUDAToolkit 13.3 REQUIRED)

set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)

add_executable(race_conditions_demo src/race_conditions_demo.cu)
target_link_libraries(race_conditions_demo PRIVATE CUDA::cudart Threads::Threads)

# Deliberately do NOT enable ThreadSanitizer or similar here by default --
# the whole point of Part 1 is observing the race's real-world effect.
# A sanitizer build is a legitimate and useful thing to try separately
# (see the README), but it changes the demonstrated behavior.
