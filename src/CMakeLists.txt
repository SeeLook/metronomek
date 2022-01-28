##############################################################################
# This file is part of Metronomek                                            #
# Copyright (C) 2021-2022 by Tomasz Bojczuk (seelook@gmail.com)              #
# on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)            #
##############################################################################

if (APPLE) # Mac RPath
  set(CMAKE_MACOSX_RPATH 1)
  set(CMAKE_INSTALL_RPATH "@loader_path/../Frameworks")
  set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
endif (APPLE)

option(USE_SOUNDTOUCH "Use SoundTouch library to squash verbal counting audio data" OFF)
if (${USE_SOUNDTOUCH})
  add_compile_definitions(WITH_SOUNDTOUCH)
endif()

if (NOT ANDROID)
  add_subdirectory(rtaudio)
endif()

set(METRONOMEK_SRC
    main.cpp
    tglob.cpp
    tsound.cpp
    tabstractaudiodevice.cpp
    tsounddata.cpp
    tnumeralspectrum.cpp
    trtaudioout.cpp
    tcountingmanager.cpp
    tmetroshape.cpp
    #taudiobuffer.h Android Qt Audio, TODO rather to remove

    tspeedhandler.cpp
    ttempopart.cpp

    qml/metronomek_qml.qrc
    ${CMAKE_SOURCE_DIR}/images/metronomek_images.qrc
)


if (ANDROID)
    list(APPEND METRONOMEK_SRC android/tandroid.cpp)
else()
    if (UNIX)
        if (APPLE)
            add_definitions(-D__MACOSX_CORE__)
        else()
            if (ALSA_LIBRARIES)
              add_definitions(-D__LINUX_ALSA__)
            endif()
            if (PulseAudio_LIBRARIES)
              add_definitions(-D__LINUX_PULSE__)
            endif()
        endif()
    elseif (WIN32)
        add_definitions(-D__WINDOWS_WASAPI__)
        set(APP_ICON_RESOURCE_WINDOWS "${CMAKE_SOURCE_DIR}/images/metronomek.rc")
    endif()
    list(APPEND METRONOMEK_SRC rtaudio/RtAudio.cpp)
endif()

add_executable(metronomek WIN32 ${APP_ICON_RESOURCE_WINDOWS} ${METRONOMEK_SRC})

if (ANDROID)
    set_target_properties(metronomek
      PROPERTIES QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android"
    )
endif()

if (USE_SOUNDTOUCH)
  IF(SOUNDTOUCH_LIBRARIES AND SOUNDTOUCH_INCLUDE_DIRS)
    set(SOUNDTOUCH_FOUND TRUE)
  ELSE(SOUNDTOUCH_LIBRARIES AND SOUNDTOUCH_INCLUDE_DIRS)
    find_path(SOUNDTOUCH_INCLUDE_DIR
          NAMES
            soundtouch/SoundTouch.h
          PATHS
            /usr/include
            /usr/local/include
            /opt/local/include
            ${CMAKE_CURRENT_SOURCE_DIR}
            ${CMAKE_BINARY_DIR}/../soundtouch
        )

    find_library(SOUNDTOUCH_LIBRARY
          NAMES
            SoundTouch
          PATHS
            /usr/lib
            /usr/lib64
            /usr/local/lib
            /opt/local/lib
            /sw/lib
            ${CMAKE_BINARY_DIR}/../soundtouch
            ${CMAKE_CURRENT_SOURCE_DIR}
    )

    set(SOUNDTOUCH_INCLUDE_DIRS
      ${SOUNDTOUCH_INCLUDE_DIR}
    )
    set(SOUNDTOUCH_LIBRARIES
      ${SOUNDTOUCH_LIBRARY}
    )

    IF(SOUNDTOUCH_INCLUDE_DIRS AND SOUNDTOUCH_LIBRARIES)
      set(SOUNDTOUCH_FOUND TRUE)
    ENDIF(SOUNDTOUCH_INCLUDE_DIRS AND SOUNDTOUCH_LIBRARIES)

    IF(SOUNDTOUCH_FOUND)
        message(STATUS "SoundTouch was Found in:\n${SOUNDTOUCH_LIBRARIES}\nheaders are in: ${SOUNDTOUCH_INCLUDE_DIRS}")
    ELSE(SOUNDTOUCH_FOUND)
        message(FATAL_ERROR "Could not find SoundTouch\nTry call cmake with args:\n-DSOUNDTOUCH_LIBRARIES=/path_to/libSoundTouch.la(dll) -DSOUNDTOUCH_INCLUDE_DIRS=/path_to_dir_with/libSoundTouch.h\nor put those files in build dir or source dir")
    ENDIF(SOUNDTOUCH_FOUND)

  ENDIF(SOUNDTOUCH_LIBRARIES AND SOUNDTOUCH_INCLUDE_DIRS)
endif ()


target_compile_definitions(metronomek
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>
)

target_link_libraries(metronomek PRIVATE
  Qt5::Core Qt5::Gui Qt5::Quick
  ${RtAudio_LIBRARIES}
  ${SOUNDTOUCH_LIBRARY}
)

if (APPLE) # info.plist
  find_program(GIT_CMD git)
  if (GIT_CMD)
    execute_process(COMMAND ${GIT_CMD} -C ${CMAKE_SOURCE_DIR} rev-list HEAD --count OUTPUT_VARIABLE MAC_BUNDLE_VER OUTPUT_STRIP_TRAILING_WHITESPACE)
  else()
    message(NOTICE "!! Missing git command - cannot obtain MACOSX_BUNDLE_BUNDLE_VERSION !!")
  endif()

  configure_file(${CMAKE_SOURCE_DIR}/installs/Mac/info.plist.in ${CMAKE_BINARY_DIR}/info.plist)
  install(FILES "${CMAKE_BINARY_DIR}/info.plist" DESTINATION "${CMAKE_INSTALL_PREFIX}/metronomek.app/Contents")

endif()


