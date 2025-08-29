##############################################################################
# This file is part of Metronomek                                            #
# Copyright (C) 2021-2022 by Tomasz Bojczuk (seelook@gmail.com)              #
# on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)            #
##############################################################################

cmake_minimum_required(VERSION 3.16)

set(METRONOMEK_VER "0.6.7-devel")
#WARNING Keep above line exactly as 9th line of this file.
#        Needed for CD/CI to obtain version

if (POLICY CMP0071)
  cmake_policy(SET CMP0071 NEW)
endif()

if (WIN32)
  # GitHub actions use this file to get version number
  file(WRITE ${CMAKE_BINARY_DIR}/VERSION.txt "${METRONOMEK_VER}")
endif()

project(metronomek LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(ANDROID)
    find_package(QT NAMES Qt6 COMPONENTS Core Gui Quick LinguistTools REQUIRED)
    find_package(Qt6 COMPONENTS Core Gui Quick REQUIRED)
else()
    find_package(QT NAMES Qt6 COMPONENTS Core Widgets Quick LinguistTools REQUIRED)
    find_package(Qt6 COMPONENTS Core Widgets Quick REQUIRED)
endif()
qt_standard_project_setup(REQUIRES 6.8)

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

# Sound samples
install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/sounds" DESTINATION "${INS_PREF}")

install(FILES LICENSE CHANGELOG.md DESTINATION "${INS_PREF}")

# translations (*.qm)
file(GLOB QM_STUFF "${CMAKE_CURRENT_SOURCE_DIR}/translations/*.qm")
install(FILES ${QM_STUFF} DESTINATION "${INS_PREF}/translations")

# Icons & other stuff
if (WIN32)
    install(FILES resources/metronomek.ico resources/pack.ico resources/logo.bmp DESTINATION "${INS_PREF}/images")
    # MINGW libraries and SSL
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
      install(FILES "${CMAKE_SOURCE_DIR}/resources/metronomek.icns" DESTINATION "${INS_PREF}")
    else() # Linux
        install(FILES installs/Linux/net.sf.metronomek.desktop DESTINATION share/applications)
        install(FILES installs/Linux/net.sf.metronomek.appdata.xml DESTINATION share/metainfo)
        install(FILES resources/hicolor/16x16/apps/metronomek.png DESTINATION share/icons/hicolor/16x16/apps/)
        install(FILES resources/hicolor/24x24/apps/metronomek.png DESTINATION share/icons/hicolor/24x24/apps/)
        install(FILES resources/hicolor/32x32/apps/metronomek.png DESTINATION share/icons/hicolor/32x32/apps/)
        install(FILES resources/hicolor/48x48/apps/metronomek.png DESTINATION share/icons/hicolor/48x48/apps/)
        install(FILES resources/hicolor/64x64/apps/metronomek.png DESTINATION share/icons/hicolor/64x64/apps/)
        install(FILES resources/hicolor/128x128/apps/metronomek.png DESTINATION share/icons/hicolor/128x128/apps/)
        install(FILES resources/hicolor/256x256/apps/metronomek.png DESTINATION share/icons/hicolor/256x256/apps/)
        install(FILES resources/metronomek.png DESTINATION share/icons/hicolor/512x512/apps/)
    endif()
endif()

##############################################################################
#                 src target                                                 #
#                  (Linux)                                                   #
##############################################################################
if(UNIX AND NOT APPLE)
  message(STATUS "
    To build source package, call:
    make src
  ")
  add_custom_target(src
    COMMAND ${CMAKE_SOURCE_DIR}/installs/make-src.sh ${METRONOMEK_VER} ${CMAKE_BINARY_DIR} ${CMAKE_SOURCE_DIR}
  )
endif()

##############################################################################
#         runinplace target                                                  #
#         (Linux & Mac Os)                                                   #
##############################################################################
if (UNIX AND NOT ANDROID)
  message(STATUS "
    To enable launching MetronomeK without installing, call:
    make runinplace
    and launch it invoking: ./src/metronomek
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

get_target_property(QtCore_location_Release Qt6::Core LOCATION_Release)
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
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/installs/Linux/make-appimage.sh ${CMAKE_SOURCE_DIR} ${CMAKE_BINARY_DIR} ${QT_QMAKE_EXECUTABLE} ${METRONOMEK_VER}
  )
endif()

##############################################################################
#                dmg target                                                  #
#                (Mac Os)                                                    #
##############################################################################
if (APPLE)
  add_custom_target(dmg
    COMMAND echo "creating dmg image..."
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/installs/Mac/create-dmg.sh ${METRONOMEK_VER} ${CMAKE_SOURCE_DIR} ${CMAKE_INSTALL_PREFIX}
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


#add_subdirectory(spare_parts/helpers/wavdirparser)
