##############################################################################
# This file is part of Metronomek                                            #
# Copyright (C) 2022-2025 by Tomasz Bojczuk (seelook@gmail.com)              #
# on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)            #
##############################################################################

cmake_minimum_required(VERSION 3.16)

project(wavdirparser LANGUAGES CXX)

find_package(Qt6 REQUIRED COMPONENTS Widgets Qml Quick QuickControls2)
set(QT_DEFAULT_MAJOR_VERSION 6)
qt_standard_project_setup(REQUIRES 6.8)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)

set(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/../../../src/)

include_directories(../../../src)

set(WAVDIRPARSER_SRC
        main.cpp
        ../../../src/fromqt5lang.cpp
)

add_executable(wavdirparser ${WAVDIRPARSER_SRC})
target_link_libraries(wavdirparser Qt6::Core)
