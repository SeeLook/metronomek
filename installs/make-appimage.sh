#! /bin/sh

###################################################################################
# creates directory structure with all stuff (libraries, icons, etc.),            #
# then creates AppImage                                                           #
#                                                                                 #
# Copyright (C) 2021 by Tomasz Bojczuk <seelook@gmail.com>                        #
#                                                                                 #
# Arguments:                                                                      #
# - source directory                                                              #
# - build directory                                                               #
# - qmake executable path                                                         #
# - Metronomek version                                                                #
# install linuxdeployqt & appimagetool first - they have to be in $PATH           #
# or they will be downloaded                                                      #
#                                                                                 #
# To correctly generate AppImage set install prefix to '/usr'                     #
# and when using with older Linux system (i.e. Ubuntu Trusty 14.04)               #
# call                                                                            #
# cmake with -DQT_QMAKE_EXECUTABLE=/opt/qtXX/bin/qmake                            #
###################################################################################


SRC_DIR=$1
BIN_DIR=$2
QMAKE=$3
VERSION=$4

printf "\033[01;35mCreating directory AppDir for AppImage of Metronomek-$VERSION"
printf "\033[01;00m"
echo "\n"
echo "qmake found in: $QMAKE"

cd $BIN_DIR

if [ "$( whereis linuxdeployqt | grep '\/' )" ]; then
  echo "-- linuxdeployqt was found"
  LIN_DEP_QT=linuxdeployqt
else
  echo "-- fetching linuxdeployqt"
  wget -c -nv "https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage"
  chmod a+x linuxdeployqt-continuous-x86_64.AppImage
  LIN_DEP_QT="./linuxdeployqt-continuous-x86_64.AppImage --appimage-extract-and-run"
fi

if [ -d AppDir ]; then
  echo "AppDir already exists... deleting"
  rm -r AppDir
fi

mkdir AppDir

#Install to AppDir
make DESTDIR="AppDir/" install

export PATH="$QMAKE:$PATH"


# desktop integration files TODO
# mv AppDir/usr/share/metainfo/metronomek.appdata.xml AppDir/usr/share/metainfo/sf.net.metronomek.appdata.xml

$LIN_DEP_QT AppDir/usr/share/applications/*.desktop -bundle-non-qt-libs -qmldir=$SRC_DIR/src/qml -qmake=$QMAKE -appimage



# Obtain git commits number
BUILD=$(git -C $SRC_DIR rev-list HEAD --count)
mv MetronomeK*.AppImage Metronomek-$VERSION-b$BUILD-x86_64.AppImage



