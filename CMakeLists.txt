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

if (Qt5Widgets_FOUND)
  if (Qt5Widgets_VERSION VERSION_LESS 5.12.0)
    message(FATAL_ERROR "Minimum supported Qt version is 5.12.0")
  endif()
endif()

configure_file(${CMAKE_SOURCE_DIR}/src/metronomek_conf_cmake.h.in ${CMAKE_CURRENT_BINARY_DIR}/src/metronomek_conf.h)

include_directories(${CMAKE_CURRENT_BINARY_DIR})

##############################################################################
#               Compilation                                                  #
#          (inside src directory)                                            #
##############################################################################
add_subdirectory(src)

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
    install(FILES images/metronomek.ico images/pack.ico images/logo.bmp DESTINATION "${INS_PREF}/images")
    # MINGW libraries
    if (COPY_GCC_LIBS)
      get_filename_component(MAKE_DIR "${CMAKE_RC_COMPILER}" DIRECTORY)
      install(FILES "${MAKE_DIR}/libgcc_s_dw2-1.dll" "${MAKE_DIR}/libstdc++-6.dll" "${MAKE_DIR}/libwinpthread-1.dll" DESTINATION "${INS_PREF}")
    endif()
    configure_file(
      ${CMAKE_CURRENT_SOURCE_DIR}/installs/Windows/definitions.nsh.in
      ${CMAKE_BINARY_DIR}/NSIS.definitions.nsh
    )
    install(FILES installs/Windows/metronomek.nsi ${CMAKE_BINARY_DIR}/NSIS.definitions.nsh DESTINATION ${INS_PREF})
else()
    if(APPLE)
      install(FILES "${CMAKE_SOURCE_DIR}/images/metronomek.icns" DESTINATION "${INS_PREF}")
    else() # Linux
        install(FILES installs/net.sf.metronomek.desktop DESTINATION share/applications)
        install(FILES installs/net.sf.metronomek.appdata.xml DESTINATION share/metainfo)
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

##############################################################################
#            deploy target                                                   #
#         (Mac Os & Windows)                                                 #
##############################################################################

get_target_property(QtCore_location_Release Qt5::Core LOCATION_Release)
get_filename_component(QT_BINARY_DIR "${QtCore_location_Release}" DIRECTORY)

if (APPLE)
  add_custom_target(deploy
    COMMAND echo "deploying..."
    COMMAND ${QT_BINARY_DIR}/../../bin/macdeployqt ${CMAKE_INSTALL_PREFIX}/metronomek.app -qmldir=${CMAKE_SOURCE_DIR}/src/qml
  )
endif()

if (WIN32)
  add_custom_target(deploy
    COMMAND echo "deploying..."
    COMMAND ${QT_BINARY_DIR}/windeployqt.exe ${CMAKE_INSTALL_PREFIX}/metronomek.exe --no-translations --no-svg --qmldir "${CMAKE_SOURCE_DIR}/src/qml"
  )
endif()

##############################################################################
#            AppImage target                                                 #
#                (Linux)                                                     #
##############################################################################
if (UNIX AND NOT APPLE)
  # To correctly generate AppImage set install prefix to '/usr'
  # and when using with older Linux system (i.e. Ubuntu Trusty 14.04)
  # call
  # cmake with -DQT_QMAKE_EXECUTABLE=/opt/qtXX/bin/qmake
  add_custom_target(appimage
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/installs/make-appimage.sh ${CMAKE_SOURCE_DIR} ${CMAKE_BINARY_DIR} ${QT_QMAKE_EXECUTABLE} ${METRONOMEK_VER}
  )
endif()

##############################################################################
#                 uninstall target                                           #
##############################################################################
configure_file(
     "${CMAKE_CURRENT_SOURCE_DIR}/installs/cmake_uninstall.cmake.in"
     "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
        IMMEDIATE @ONLY)

  add_custom_target(uninstall
   COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake
)
