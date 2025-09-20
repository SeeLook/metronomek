##############################################################################
# This file is part of Metronomek                                            #
# Copyright (C) 2021-2025 by Tomasz Bojczuk (seelook@gmail.com)              #
# on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)            #
##############################################################################

find_package(Qt6 REQUIRED COMPONENTS Widgets Qml Quick QuickControls2)

set(QT_DEFAULT_MAJOR_VERSION 6)

qt_standard_project_setup(REQUIRES 6.8)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(QT_QML_GENERATE_QMLLS_INI ON)

if (APPLE) # Mac RPath
    set(CMAKE_MACOSX_RPATH 1)
    set(CMAKE_INSTALL_RPATH "@loader_path/../Frameworks")
    set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
endif (APPLE)

if (ANDROID)
    set(OPEN_SSL_CMAKE android_openssl/android_openssl.cmake)
    include(${OPEN_SSL_CMAKE} RESULT_VARIABLE ANDROID_SSL_STATE)
    message(STATUS "SSL: ${ANDROID_SSL_STATE} === ${OPEN_SSL_CMAKE}")
endif()

qt_add_executable(metronomek)

option(USE_SOUNDTOUCH "Use SoundTouch library to squash verbal counting audio data" OFF)
if (${USE_SOUNDTOUCH})
    add_compile_definitions(WITH_SOUNDTOUCH)
endif()

if (NOT ANDROID)
    add_subdirectory(rtaudio)
endif()

set(METRONOMEK_SRC
    main.cpp
    tabstractaudiodevice.cpp
    tsounddata.cpp
    tgetfile.cpp

    qml/metronomek_qml.qrc
    ${CMAKE_SOURCE_DIR}/resources/metronomek_res.qrc
)

set(METRONOMEK_QML_SINGLETONS
    qml/ActivPalette.qml
    qml/DisblPalette.qml
    qml/FM.qml
)

set_source_files_properties(${METRONOMEK_QML_SINGLETONS}
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

set(METRONOMEK_QML_ANDROID
    qml/MaterialImport.qml
)

# qt_add_resources(METRONOMEK_SRC ${CMAKE_SOURCE_DIR}/resources/metronomek_res.qrc)

qt_add_qml_module(metronomek
    URI "Metronomek.Core"
    QML_FILES
        qml/MainWindow.qml
        qml/Logo.qml
        qml/MainMenuButton.qml
        qml/MainDrawerContent.qml
        qml/DrawerButton.qml
        qml/MeterDrawer.qml
        qml/MetroImage.qml

        qml/InfoPage.qml
        qml/SettingsPage.qml
        qml/TempoPage.qml
        qml/VerbalCountPage.qml
        qml/VerbalCountEdit.qml
        qml/TempoEdit.qml
        qml/TempoPartDelegate.qml
        qml/DragDelegate.qml
        qml/CompositionView.qml
        qml/NextTempoPop.qml
        qml/CountingLangPop.qml

        qml/Background.qml
        qml/TipRect.qml
        qml/CuteButton.qml
        qml/TspinBox.qml
        qml/Tdialog.qml
        qml/LinkText.qml
        qml/SidePop.qml
        qml/HelpPop.qml

        ${METRONOMEK_QML_ANDROID}
        ${METRONOMEK_QML_SINGLETONS}

    SOURCES
        tglob.cpp
        tglob.h
        tsound.cpp
        tsound.h

        tmetroshape.cpp
        tmetroshape.h
        ttempopart.cpp
        ttempopart.h
        tspeedhandler.cpp
        tspeedhandler.h
        tcountingmanager.cpp
        tcountingmanager.h
        tnumeralspectrum.cpp
        tnumeralspectrum.h

    DEPENDENCIES
        QtQuick
)

if (ANDROID)
    set (OBOE_DIR oboe)
    add_subdirectory(${OBOE_DIR} ./oboe)
    include_directories(${OBOE_DIR}/include)
    include_directories(${OBOE_DIR}/src)

    list(APPEND METRONOMEK_SRC
        tandroid.cpp
        toboedevice.cpp
    )
    add_android_openssl_libraries(metronomek)
else()
    list(APPEND METRONOMEK_SRC
        trtaudiodevice.cpp
    )
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
        set(APP_ICON_RESOURCE_WINDOWS "${CMAKE_SOURCE_DIR}/resources/metronomek.rc")
    endif()
    list(APPEND METRONOMEK_SRC rtaudio/RtAudio.cpp)
endif()

if (USE_SOUNDTOUCH)
    IF(SOUNDTOUCH_LIBRARIES AND SOUNDTOUCH_INCLUDE_DIRS)
        set(SOUNDTOUCH_FOUND TRUE)
    else(SOUNDTOUCH_LIBRARIES AND SOUNDTOUCH_INCLUDE_DIRS)
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

        set(SOUNDTOUCH_INCLUDE_DIRS ${SOUNDTOUCH_INCLUDE_DIR})
        set(SOUNDTOUCH_LIBRARIES ${SOUNDTOUCH_LIBRARY})

        IF(SOUNDTOUCH_INCLUDE_DIRS AND SOUNDTOUCH_LIBRARIES)
            set(SOUNDTOUCH_FOUND TRUE)
        endif()

        IF(SOUNDTOUCH_FOUND)
            message(STATUS "SoundTouch was Found in:\n${SOUNDTOUCH_LIBRARIES}\nheaders are in: ${SOUNDTOUCH_INCLUDE_DIRS}")
        else()
            message(FATAL_ERROR "Could not find SoundTouch\nTry call cmake with args:\n-DSOUNDTOUCH_LIBRARIES=/path_to/libSoundTouch.la(dll) -DSOUNDTOUCH_INCLUDE_DIRS=/path_to_dir_with/libSoundTouch.h\nor put those files in build dir or source dir")
        endif()

    endif ()
endif ()

target_sources(metronomek PUBLIC
    ${METRONOMEK_SRC}
    ${APP_ICON_RESOURCE_WINDOWS}
)

target_link_libraries(metronomek PUBLIC
    Qt6::Core
    Qt6::Widgets
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    ${SOUNDTOUCH_LIBRARY}
)

if(ANDROID)
    target_link_libraries(metronomek PUBLIC
        OpenSLES
        oboe
    )
    set(QT_ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_SOURCE_DIR}/installs/android)

    set_target_properties(metronomek PROPERTIES
        QT_ANDROID_PACKAGE_SOURCE_DIR ${QT_ANDROID_PACKAGE_SOURCE_DIR}
        QT_ANDROID_PACKAGE_NAME "net.sf.metronomek"
        QT_ANDROID_MIN_SDK_VERSION 23
        QT_ANDROID_TARGET_SDK_VERSION 36
        QT_ANDROID_VERSION_CODE 10
        QT_ANDROID_APP_NAME "metronomek"
        QT_ANDROID_VERSION_NAME ${METRONOMEK_VER}
    )

    message(STATUS "
        Metronomek ${METRONOMEK_VER} for Android
        ${QT_ANDROID_PACKAGE_SOURCE_DIR}
        "
    )

    # install(TARGETS metronomek
    #     BUNDLE DESTINATION .
    #     LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    #     RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    # )

else()
    if (LINUX)
        target_compile_definitions(metronomek
            PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>
        )
    endif()
    set_target_properties(metronomek PROPERTIES
        WIN32_EXECUTABLE ON
        MACOSX_BUNDLE ON
    )
    target_link_libraries(metronomek PUBLIC
        ${RtAudio_LIBRARIES}
    )
endif()

if(WIN32)
    install(TARGETS metronomek RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
else()
    if (APPLE)
        install(TARGETS metronomek DESTINATION "${CMAKE_INSTALL_PREFIX}/metronomek.app/Contents/MacOs")
        set(INS_PREF "metronomek.app/Contents/Resources")
    else()
        install(TARGETS metronomek DESTINATION bin)
        set(INS_PREF "share/metronomek")
    endif()
endif()

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


