# This file is part of Metronomek
# Copyright (C) 2019-2020 by Tomasz Bojczuk (seelook@gmail.com)
# on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)

android: TARGET = MetronomeK
else: {
  TARGET = metronomek
  error("To configure and build MetronomeK for desktop PC (Linux, Mac Windows) use cmake! This qmake script is for Android only!")
}

TEMPLATE = app

VERSION = 0.5-devel
QMAKE_SUBSTITUTES += src/metronomek_conf.h.in

QT += multimedia gui quick quickcontrols2 androidextras

CONFIG += c++11

# Actually it has to be 5.14 for Android due to newer manifest quirks
!versionAtLeast(QT_VERSION, 5.14.0) {
    message("Cannot use Qt $${QT_VERSION}")
    error("Use Qt 5.14 or newer")
}

DEFINES += QT_DEPRECATED_WARNINGS
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        src/main.cpp \
        src/tglob.cpp \
        src/taudioout.cpp \
        src/tabstractaudiooutput.cpp \
        src/tqtaudioout.cpp \
        src/tmetroshape.cpp \
        \
        src/android/tandroid.cpp \

HEADERS += \
        src/tglob.h \
        src/taudiobuffer.h \
        src/taudioout.h \
        src/tabstractaudiooutput.h \
        src/tqtaudioout.h \
        src/tmetroshape.h \
        \
        src/android/tandroid.h\

RESOURCES += src/metronomek.qrc

sounds.path = /assets/sounds
translations.path = /assets/translations

sounds.files = $$files(sounds/*.raw48-16, true)
sounds.depends += FORCE

translations.files = $$files(translations/*.qm, true)
translations.depends += FORCE

license.files = LICENSE

INSTALLS += sounds translations

android {
  DISTFILES += \
    android/AndroidManifest.xml \
    android/build.gradle \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew \
    android/gradlew.bat \
    android/res/values/libs.xml

  ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
}
