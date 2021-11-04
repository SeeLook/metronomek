##############################################################################
# This file is part of Metronomek                                            #
# Copyright (C) 2021 by Tomasz Bojczuk (seelook@gmail.com)                   #
# on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)            #
##############################################################################

cmake_minimum_required(VERSION 3.14)

set(METRONOMEK_VER "0.5.0-devel")

project(metronomek LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(QT NAMES Qt5 COMPONENTS Core Gui Quick REQUIRED)
find_package(Qt5 COMPONENTS Core Gui Quick REQUIRED)

configure_file(${CMAKE_SOURCE_DIR}/src/metronomek_conf_cmake.h.in ${CMAKE_CURRENT_BINARY_DIR}/src/metronomek_conf.h)

include_directories(${CMAKE_CURRENT_BINARY_DIR})

if (NOT ANDROID)
    add_subdirectory(src/rtaudio)
endif()

set(METRONOMEK_SRC
    src/main.cpp
    src/tglob.cpp
    src/taudioout.cpp
    src/tabstractaudiooutput.cpp
    src/trtaudioout.cpp
    src/tmetroshape.cpp
    src/taudiobuffer.h
    src/metronomek.qrc
)

if (ANDROID)
    list(APPEND METRONOMEK_SRC src/android/tandroid.cpp)
else()
    if (ALSA_LIBRARIES)
      add_definitions(-D__LINUX_ALSA__)
    endif()
    if (PulseAudio_LIBRARIES)
      add_definitions(-D__LINUX_PULSE__)
    endif()
    list(APPEND METRONOMEK_SRC src/rtaudio/RtAudio.cpp)
endif()

add_executable(metronomek
    ${METRONOMEK_SRC}
)

if (ANDROID)
    set_target_properties(metronomek
      PROPERTIES QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android"
    )
endif()


target_compile_definitions(metronomek
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>
)

target_link_libraries(metronomek PRIVATE
  Qt5::Core Qt5::Gui Qt5::Quick
  ${RtAudio_LIBRARIES}
)

set_target_properties(metronomek PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER org.seelook.metronomek
    MACOSX_BUNDLE_BUNDLE_VERSION 1 # TODO - get git commits number here ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${METRONOMEK_VER}
)

##############################################################################
#              Installation                                                  #
#         (ignored under Android)                                            #
##############################################################################
if(WIN32)
    install(TARGETS metronomek DESTINATION .)
    set(INS_PREF ".")
    option(COPY_GCC_LIBS "Copy compiler specific libraries during install target" ON)
else()
    if (APPLE)
        install(TARGETS metronomek DESTINATION "${CMAKE_INSTALL_PREFIX}/metronomek.app/Contents/MacOs")
        set(INS_PREF "metronomek.app/Contents/Resources")
    else()
        install(TARGETS metronomek DESTINATION bin)
        set(INS_PREF "share/metronomek")
    endif()
endif()

# Beat sound samples
file(GLOB BEAT_FILES "${CMAKE_CURRENT_SOURCE_DIR}/sounds/*.raw48-16")
install(FILES ${BEAT_FILES} DESTINATION "${INS_PREF}/sounds")

install(FILES LICENSE DESTINATION "${INS_PREF}")

# translations (*.qm)
file(GLOB QM_STUFF "${CMAKE_CURRENT_SOURCE_DIR}/translations/*.qm")
install(FILES ${QM_STUFF} DESTINATION "${INS_PREF}/translations")

# Icons & other stuff
if (WIN32)
    install(FILE installs/metronomek.nsi DESTINATION ${INS_PREF})
    install(FILES images/metronomek.ico images/pack.ico images/logo.bmp DESTINATION ${INS_PREF})
    # MINGW libraries
    if (COPY_GCC_LIBS)
      get_filename_component(MAKE_DIR "${CMAKE_RC_COMPILER}" DIRECTORY)
      install(FILES "${MAKE_DIR}/libgcc_s_dw2-1.dll" "${MAKE_DIR}/libstdc++-6.dll" "${MAKE_DIR}/libwinpthread-1.dll" DESTINATION "${INS_PREF}")
    endif()
else()
    if(APPLE)
      # TODO
    else() # Linux
        install(FILES installs/metronomek.desktop DESTINATION share/applications)
        install(FILES images/hicolor/16x16/apps/metronomek.png DESTINATION share/icons/hicolor/16x16/apps/)
        install(FILES images/hicolor/24x24/apps/metronomek.png DESTINATION share/icons/hicolor/24x24/apps/)
        install(FILES images/hicolor/32x32/apps/metronomek.png DESTINATION share/icons/hicolor/32x32/apps/)
        install(FILES images/hicolor/48x48/apps/metronomek.png DESTINATION share/icons/hicolor/48x48/apps/)
        install(FILES images/hicolor/64x64/apps/metronomek.png DESTINATION share/icons/hicolor/64x64/apps/)
        install(FILES images/hicolor/128x128/apps/metronomek.png DESTINATION share/icons/hicolor/128x128/apps/)
        install(FILES images/hicolor/256x256/apps/metronomek.png DESTINATION share/icons/hicolor/256x256/apps/)
        install(FILES images/metronomek.png DESTINATION share/icons/hicolor/512x512/apps/)
    endif()
endif()


##############################################################################
#         runinplace target                                                  #
#         (Linux & Mac Os)                                                   #
##############################################################################
if (UNIX AND NOT ANDROID)
  message(STATUS "
    To enable launching MetronomeK without installing, call:
    make runinplace
    and launch it invoking: ./metronomek
    "
  )
  if (APPLE)
      set(LINK_PATH "${CMAKE_BINARY_DIR}/Resources")
  else ()
      set(LINK_PATH "${CMAKE_BINARY_DIR}")
  endif()
  add_custom_target(runinplace
      COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/installs/make-runinplace.sh ${CMAKE_SOURCE_DIR} ${LINK_PATH}
  )
endif()
