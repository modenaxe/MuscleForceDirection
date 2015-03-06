# you should define the following ENVIRONMENT VARIABLES:
# - CEINMS_INSTALL_DIR
# where you should already have:
#    the Concurrency library
#    the Code library
#    the Filter library
# - VICONDATASTREAM_INSTALL_DIR
# with:
# include/Client.h
# lib/libDebugServices.so  lib/libViconDataStreamSDK_CPP.so

cmake_minimum_required (VERSION 2.8.5)
project(MuscleForceDirection)

set(CMAKE_BUILD_TYPE Release)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_SOURCE_DIR})
find_package(OpenSim)

add_subdirectory(lib)
