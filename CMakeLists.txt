##############################################################################
# This file is part of Metronomek                                            #
# Copyright (C) 2021 by Tomasz Bojczuk (seelook@gmail.com)                   #
# on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)            #
##############################################################################

cmake_minimum_required(VERSION 3.14)

set(METRONOMEK_VER 0.4.9)

project(metronomek VERSION ${METRONOMEK_VER} LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(QT NAMES Qt6 COMPONENTS Core Gui Quick LinguistTools REQUIRED)
find_package(Qt6 COMPONENTS Core Gui Quick REQUIRED)

configure_file(${CMAKE_SOURCE_DIR}/src/metronomek_conf.h.in ${CMAKE_CURRENT_BINARY_DIR}/src/metronomek_conf.h)

include_directories(${CMAKE_CURRENT_BINARY_DIR})

set(METRONOMEK_SRC
    src/main.cpp
    src/tglob.cpp
    src/taudioout.cpp
    src/tmetroshape.cpp
    src/metronomek.qrc
)

if (ANDROID)
    list(APPEND METRONOMEK_SRC src/android/tandroid.cpp)
endif()

qt_add_executable(metronomek
    MANUAL_FINALIZATION
    ${METRONOMEK_SRC}
)
# Define target properties for Android with Qt 6 as:
#    set_property(TARGET metronomek APPEND PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR
#                 ${CMAKE_CURRENT_SOURCE_DIR}/android)
# For more information, see https://doc.qt.io/qt-6/qt-add-executable.html#target-creation


if (ANDROID)
    set_target_properties(metronomek
      PROPERTIES QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android"
    )
else()
    add_subdirectory(src/rtaudio)
endif()


target_compile_definitions(metronomek
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>
)

target_link_libraries(metronomek PRIVATE
  Qt6::Core Qt6::Gui Qt6::Quick
  ${ALSA_LINK} ${PulseAudio_LINK}
)

set_target_properties(metronomek PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER org.seelook.metronomek
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
)

qt_import_qml_plugins(metronomek)
qt_finalize_executable(metronomek)


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
