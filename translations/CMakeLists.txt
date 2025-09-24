########################################################################
######   Cmake rules for creating Nootka translation files *.qm   ######
########################################################################

find_package(Qt6 COMPONENTS LinguistTools)

file(GLOB TR_SOURCES "metronomek_*.ts")

qt_add_translations(metronomek
    TS_FILES ${TR_SOURCES}
    QM_FILES_OUTPUT_VARIABLE QM_FILES
)

# HACK: above command doesn't want to invoke itself.
# Following trick is needed
add_custom_target(translations ALL DEPENDS ${QM_FILES})

if(APPLE OR WIN32)
    find_package(Qt6Core)
    get_target_property(QtCore_location_Release Qt6::Core LOCATION_Release)
    get_filename_component(QT_BINARY_DIR "${QtCore_location_Release}" DIRECTORY)
    if(WIN32)
        if(NOT DEFINED QT_TRANSLATIONS_DIR)
            set(QT_TRANSLATIONS_DIR "${QT_BINARY_DIR}/../translations")
        endif()
    else()
        set(QT_TRANSLATIONS_DIR "${QT_BINARY_DIR}/../../translations")
    endif()
endif()

if(ANDROID)
    add_custom_command(
        TARGET translations
        POST_BUILD
        COMMAND sh ${CMAKE_SOURCE_DIR}/installs/android-translations-asset.sh ${CMAKE_SOURCE_DIR} ${CMAKE_BINARY_DIR}
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "--- adding translations to assets ---"
    )
else()
    message(STATUS "Translations: ${INS_PREF}/translations")
    install(FILES ${QM_FILES} DESTINATION "${INS_PREF}/translations")
endif()
