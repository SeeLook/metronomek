# This file is part of Metronomek
# Copyright (C) 2019-2020 by Tomasz Bojczuk (seelook@gmail.com)
# on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)

android: TARGET = Metronomek
else: TARGET = metronomek

TEMPLATE = app

VERSION = 0.4
QMAKE_SUBSTITUTES += src/metronomek_conf.h.in

QT += multimedia widgets quick quickcontrols2

CONFIG += c++11

# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Refer to the documentation for the
# deprecated API to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        src/main.cpp \
        src/tglob.cpp \
        src/tmetroitem.cpp \
        src/taudioout.cpp \

HEADERS += \
        src/tglob.h \
        src/tmetroitem.h \
        src/taudiobuffer.h \
        src/taudioout.h \


RESOURCES += src/metronomek.qrc

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /bin
else: windows: target.path = /
!isEmpty(target.path): INSTALLS += target

linux:!android {
  sounds.path = /share/metronomek/Sounds
  # build executable in scr dir to keep '../share/metronome/Sounds' path valid during debug
  DESTDIR = src
}
android {
  sounds.path = /assets/Sounds
}
windows {
  sounds.path = /Sounds
}
sounds.files = $$files(Sounds/*.raw48-16, true)
sounds.depends += FORCE

INSTALLS += sounds

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
