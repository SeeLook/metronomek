#! /bin/bash

# Copyright (C) 2020 by Tomasz Bojczuk (seelook@gmail.com)
# on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)

# Script for building MetronomeK source tar-ball package
# It usually it is invoked by make src
# USAGE:
# make-src.sh version build-directory source-directory

VERSION=$1
BUILD_DIR=$2
SRC_DIR=$3
DST_DIR=metronomek-$VERSION-source

printf "\033[01;35mGenerating source package for \033[01;32m$DST_DIR"
printf "\033[01;00m"
echo

cd $BUILD_DIR
mkdir $DST_DIR

cp -r $SRC_DIR/images $DST_DIR
cp -r $SRC_DIR/sounds $DST_DIR
cp -r $SRC_DIR/android $DST_DIR
cp -r $SRC_DIR/fonts $DST_DIR
cp -r $SRC_DIR/installs $DST_DIR
cp -r $SRC_DIR/src $DST_DIR
cp -r $SRC_DIR/translations $DST_DIR

cp $SRC_DIR/LICENSE $DST_DIR
cp $SRC_DIR/README.md $DST_DIR
cp $SRC_DIR/TODO.md $DST_DIR
cp $SRC_DIR/metronomek.pro $DST_DIR

tar -cjf $DST_DIR.tar.bz2 $DST_DIR
rm -r $DST_DIR
