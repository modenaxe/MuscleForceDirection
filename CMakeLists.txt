cmake_minimum_required (VERSION 2.8.5)
project(MuscleForceDirection)

set(CMAKE_BUILD_TYPE Release)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_SOURCE_DIR})
find_package(OpenSim)

add_subdirectory(lib)
