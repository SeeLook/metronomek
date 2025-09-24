#! /bin/bash

# SRC_DIR - metronomek source dir
# BIN_DIR - destination dir

SRC_DIR=$1
BIN_DIR=$2

if [ -d ${SRC_DIR}/installs/android/assets/translations ]; then
    echo "Translations already added to assets. Skipping!"
    exit
else
    mkdir ${SRC_DIR}/installs/android/assets/translations
    ln -s ${BIN_DIR}/translations/*.qm ${SRC_DIR}/installs/android/assets/translations
fi
