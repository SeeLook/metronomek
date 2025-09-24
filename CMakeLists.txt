##############################################################################
# This file is part of Metronomek                                            #
# Copyright (C) 2021-2025 by Tomasz Bojczuk (seelook@gmail.com)              #
# on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)            #
##############################################################################

cmake_minimum_required(VERSION 3.16)

set(METRONOMEK_VER "0.7.7-devel")
#WARNING Keep above line exactly as 9th line of this file.
#        Needed for CD/CI to obtain version

if (POLICY CMP0071)
  cmake_policy(SET CMP0071 NEW)
endif()

if (WIN32)
    # GitHub actions use this file to get version number
    file(WRITE ${CMAKE_BINARY_DIR}/VERSION.txt "${METRONOMEK_VER}")
endif()

project(metronomek)

find_package(Qt6 REQUIRED COMPONENTS Widgets Qml Quick QuickControls2)
set(QT_DEFAULT_MAJOR_VERSION 6)
qt_standard_project_setup(REQUIRES 6.8)

set(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/src)

configure_file(${CMAKE_SOURCE_DIR}/src/metronomek_conf_cmake.h.in ${CMAKE_CURRENT_BINARY_DIR}/src/metronomek_conf.h)

##############################################################################
#                   Project sources                                          #
##############################################################################
add_subdirectory(src)

if(WIN32)
    set(INS_PREF "${CMAKE_INSTALL_BINDIR}")
else()
    if (APPLE)
        install(TARGETS metronomek DESTINATION "${CMAKE_INSTALL_PREFIX}/metronomek.app/Contents/MacOs")
        set(INS_PREF "metronomek.app/Contents/Resources")
    elseif(NOT ANDROID)
        install(TARGETS metronomek DESTINATION bin)
        set(INS_PREF "share/metronomek")
    endif()
endif()

##############################################################################
#                   Translations                                             #
##############################################################################
add_subdirectory(translations)

if (NOT ANDROID)
    # Sound samples
    install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/sounds" DESTINATION "${INS_PREF}")
    install(FILES LICENSE CHANGELOG.md DESTINATION "${INS_PREF}")
endif()

# Icons & other stuff
if (WIN32)
    install(FILES resources/metronomek.ico resources/pack.ico resources/logo.bmp DESTINATION "${INS_PREF}/images")
    qt_generate_deploy_qml_app_script(
        TARGET metronomek
        OUTPUT_SCRIPT DEPLOY_SCRIPT
        NO_TRANSLATIONS
        NO_UNSUPPORTED_PLATFORM_ERROR
    )
    install(SCRIPT ${DEPLOY_SCRIPT})
    configure_file(
        ${CMAKE_CURRENT_SOURCE_DIR}/installs/Windows/definitions.nsh.in
        ${CMAKE_BINARY_DIR}/NSIS.definitions.nsh
    )
    install(FILES installs/Windows/metronomek.nsi ${CMAKE_BINARY_DIR}/NSIS.definitions.nsh DESTINATION ${INS_PREF})
    install(CODE "
            execute_process(COMMAND ${CMAKE_COMMAND} -E rename \"${CMAKE_INSTALL_PREFIX}/plugins\" \"${CMAKE_INSTALL_PREFIX}/bin/plugins\")
            execute_process(COMMAND ${CMAKE_COMMAND} -E rename \"${CMAKE_INSTALL_PREFIX}/qml\" \"${CMAKE_INSTALL_PREFIX}/bin/qml\")
            execute_process(COMMAND ${CMAKE_COMMAND} -E remove \"${CMAKE_INSTALL_PREFIX}/bin/qt.conf\")
        "
    )
else()
    if(APPLE)
        install(FILES "${CMAKE_SOURCE_DIR}/resources/metronomek.icns" DESTINATION "${INS_PREF}")
    elseif(ANDROID)
            #
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
if(LINUX)
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
#         (Mac Os)                                                           #
##############################################################################
find_package(Qt6Core)
get_target_property(QtCore_location_Release Qt6::Core LOCATION_Release)
get_filename_component(QT_BINARY_DIR "${QtCore_location_Release}" DIRECTORY)

if (APPLE)
    add_custom_target(deploy
        COMMAND echo "deploying..."
        COMMAND ${QT_BINARY_DIR}/../../bin/macdeployqt ${CMAKE_INSTALL_PREFIX}/metronomek.app -qmldir=${CMAKE_SOURCE_DIR}/src/qml
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
if (NOT ANDROID)
    configure_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/installs/cmake_uninstall.cmake.in"
        "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
            IMMEDIATE @ONLY)

    add_custom_target(uninstall
        COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake
    )
    # add_subdirectory(spare_parts/helpers/wavdirparser)
endif()
