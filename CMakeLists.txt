##############################################################################
# This file is part of Metronomek                                            #
# Copyright (C) 2021 by Tomasz Bojczuk (seelook@gmail.com)                   #
# on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)            #
##############################################################################

cmake_minimum_required(VERSION 3.14)

project(metronomek VERSION 0.4.9 LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(QT NAMES Qt6 COMPONENTS Core Gui Quick LinguistTools REQUIRED)
find_package(Qt6 COMPONENTS Core Gui Quick REQUIRED)

configure_file(${CMAKE_SOURCE_DIR}/src/metronomek_conf.h.in ${CMAKE_CURRENT_BINARY_DIR}/src/metronomek_conf.h)

include_directories( ${CMAKE_CURRENT_BINARY_DIR} )

set(METRONOMEK_SRC
    src/main.cpp
    src/tglob.cpp
    src/taudioout.cpp
    src/tmetroshape.cpp
    src/metronomek.qrc
)

qt_add_executable(metronomek
    MANUAL_FINALIZATION
    ${METRONOMEK_SRC}
)
# Define target properties for Android with Qt 6 as:
#    set_property(TARGET metronomek APPEND PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR
#                 ${CMAKE_CURRENT_SOURCE_DIR}/android)
# For more information, see https://doc.qt.io/qt-6/qt-add-executable.html#target-creation


add_subdirectory(translations)

target_compile_definitions(metronomek
  PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>
)
target_link_libraries(metronomek
  PRIVATE Qt6::Core Qt6::Gui Qt6::Quick
)

set_target_properties(metronomek PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER my.example.com
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
)

qt_import_qml_plugins(metronomek)
qt_finalize_executable(metronomek)

message(STATUS "
  To enable launching MetronomeK without installing, call:
  make runinplace
  and launch it invoking: ./metronomek
  "
)

if (UNIX)
  if (APPLE)
    set(LINK_PATH "${CMAKE_BINARY_DIR}/Resources")
  else ()
    set(LINK_PATH "${CMAKE_BINARY_DIR}")
  endif()
  add_custom_target(runinplace
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/installs/make-runinplace.sh ${CMAKE_SOURCE_DIR} ${LINK_PATH}
  )
endif()
