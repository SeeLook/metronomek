##############################################################################
# This file is part of Metronomek                                            #
# Copyright (C) 2021 by Tomasz Bojczuk (seelook@gmail.com)                   #
# on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)            #
##############################################################################

if (NOT ANDROID)
  add_subdirectory(rtaudio)
endif()

set(METRONOMEK_SRC
    main.cpp
    tglob.cpp
    taudioout.cpp
    tabstractaudiooutput.cpp
    trtaudioout.cpp
    tmetroshape.cpp
    taudiobuffer.h
    metronomek.qrc
)


if (ANDROID)
    list(APPEND METRONOMEK_SRC android/tandroid.cpp)
else()
    if (ALSA_LIBRARIES)
      add_definitions(-D__LINUX_ALSA__)
    endif()
    if (PulseAudio_LIBRARIES)
      add_definitions(-D__LINUX_PULSE__)
    endif()
    list(APPEND METRONOMEK_SRC rtaudio/RtAudio.cpp)
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


