#! /bin/bash

# Copyright (C) 2020-2021 by Tomasz Bojczuk (seelook@gmail.com)
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

cp -r $SRC_DIR/resources $DST_DIR
cp -r $SRC_DIR/sounds $DST_DIR
cp -r $SRC_DIR/installs $DST_DIR
cp -r $SRC_DIR/src $DST_DIR
rm -r $DST_DIR/src/oboe
mkdir $DST_DIR/src/oboe
cat > $DST_DIR/src/oboe/README.md <<EOF
To build Metronomek for Android  
Clone here [Oboe git repo](https://github.com/google/oboe)
``````
git clone https://github.com/google/oboe
``````
EOF

cp -r $SRC_DIR/translations $DST_DIR

cp $SRC_DIR/LICENSE $DST_DIR
cp $SRC_DIR/*.md $DST_DIR 

cp $SRC_DIR/metronomek.pro $DST_DIR
cp $SRC_DIR/CMakeLists.txt $DST_DIR

tar -cjf $DST_DIR.tar.bz2 $DST_DIR
rm -r $DST_DIR
