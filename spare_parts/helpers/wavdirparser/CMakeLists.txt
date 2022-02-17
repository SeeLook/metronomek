##############################################################################
# This file is part of Metronomek                                            #
# Copyright (C) 2022 by Tomasz Bojczuk (seelook@gmail.com)                   #
# on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)            #
##############################################################################

cmake_minimum_required(VERSION 3.14)

project(wavdirparser LANGUAGES CXX)

find_package(QT NAMES Qt5 COMPONENTS Core REQUIRED)

set(CMAKE_AUTOMOC ON)

set(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/../../../src/)

set(WAVDIRPARSER_SRC main.cpp)

add_executable(wavdirparser ${WAVDIRPARSER_SRC})
target_link_libraries(wavdirparser Qt5::Core)
