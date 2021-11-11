#!/bin/bash

# Creates dmg image
# Takes arguments:
# $1 - version
# $2 - Metronomek sources directory path
# $3 - app bundle path

VER=$1
#Metronomek_SRC=$2
APP_PATH=$3
BUILD=$(git -C $2 rev-list HEAD --count)

hdiutil create -fs HFS+ -srcfolder $APP_PATH/metronomek.app -volname "Metronomek-$VER-b$BUILD" $APP_PATH/Metronomek-$VER-b$BUILD.dmg



