cmake_minimum_required(VERSION 3.0)
project(MuscleForceDirection VERSION 1.0.0)

if(UNIX AND NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING "Choose the build type" FORCE)
endif()

# compilation database (completion for Linux)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_subdirectory(MuscleForceDirection)
