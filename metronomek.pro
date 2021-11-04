# This file is part of Metronomek
# Copyright (C) 2019-2020 by Tomasz Bojczuk (seelook@gmail.com)
# on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)

android: TARGET = MetronomeK
else: {
  TARGET = metronomek
  error("To configure and build MetronomeK for desktop PC (Linux, Mac Windows) use cmake! This qmake script is for Android only!")
}

TEMPLATE = app

VERSION = 0.5-git
QMAKE_SUBSTITUTES += src/metronomek_conf.h.in

QT += multimedia gui quick quickcontrols2

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
        src/tmetroshape.cpp \

HEADERS += \
        src/tglob.h \
        src/taudiobuffer.h \
        src/taudioout.h \
        src/tmetroshape.h \

android {
  QT += androidextras
  SOURCES += src/android/tandroid.cpp\

  HEADERS += src/android/tandroid.h\
}

RESOURCES += src/metronomek.qrc

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /bin
else: windows: target.path = $${PREFIX}/
!isEmpty(target.path): INSTALLS += target

linux:!android {
  # build executable in scr dir to keep '../share/metronomek/sounds' path valid during debug
  DESTDIR = src
  sounds.path = /share/metronomek/sounds
  translations.path = /share/metronomek/translations
  license.path = /share/metronomek

  icon16.path = /share/icons/hicolor/16x16/apps
  icon16.files = images/hicolor/16x16/apps/metronomek.png
  icon24.path = /share/icons/hicolor/24x24/apps
  icon24.files = images/hicolor/24x24/apps/metronomek.png
  icon32.path = /share/icons/hicolor/32x32/apps
  icon32.files = images/hicolor/32x32/apps/metronomek.png
  icon48.path = /share/icons/hicolor/48x48/apps
  icon48.files = images/hicolor/48x48/apps/metronomek.png
  icon64.path = /share/icons/hicolor/64x64/apps
  icon64.files = images/hicolor/64x64/apps/metronomek.png
  icon128.path = /share/icons/hicolor/128x128/apps
  icon128.files = images/hicolor/128x128/apps/metronomek.png
  icon256.path = /share/icons/hicolor/256x256/apps
  icon256.files = images/hicolor/256x256/apps/metronomek.png

  desktop.path = /share/applications
  desktop.files = installs/metronomek.desktop
  INSTALLS += icon16 icon24 icon32 icon48 icon64 icon128 icon256 desktop

  makesrc.target = src
  makesrc.depends = first
  makesrc.commands = $${PWD}/installs/make-src.sh \"$$VERSION\" \"$$OUT_PWD\" \"$$PWD\"

  runinplace.target = runinplace
  runinplace.depends = first
  runinplace.commands = $${PWD}/installs/make-runinplace.sh \"$$PWD\" \"$$OUT_PWD\"

  QMAKE_EXTRA_TARGETS += makesrc runinplace
  INSTALLS += license
}
android {
  sounds.path = /assets/sounds
  translations.path = /assets/translations
}
windows {
  RC_ICONS = images/metronomek.ico

  sounds.path = $${PREFIX}/sounds
  translations.path = $${PREFIX}/translations
  license.path = $${PREFIX}

  qtPrepareTool(QMAKE_WINDEPLOYQT, windeployqt)
  deploy.target = deploy
  deploy.depends = first
  deploy.commands = $${QMAKE_WINDEPLOYQT} $${PREFIX}/metronomek.exe --release --no-translations --no-svg --qmldir $${PWD}/src
  QMAKE_EXTRA_TARGETS += deploy

  QMAKE_DIR = $$dirname(QMAKE_WINDEPLOYQT)

  winstuff.path = $${PREFIX}
  winstuff.files += $${QMAKE_DIR}/libgcc_s_dw2-1.dll
  winstuff.files += $${QMAKE_DIR}/libwinpthread-1.dll
  winstuff.files += $${QMAKE_DIR}/libstdc++-6.dll
  winstuff.files += installs/metronomek.nsi # Windows installer build script

  images.path= $${PREFIX}/images
  images.files += $$files(images/*.ico, true)
  images.files += $$files(images/*.bmp, true)

  INSTALLS += winstuff license images
}

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
