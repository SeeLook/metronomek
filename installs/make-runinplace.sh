#! /bin/bash

# Copyright (C) 2020-2021 by Tomasz Bojczuk (seelook@gmail.com)
# on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)

# This script creates links necessary to run MetronomeK without installation (in directory where it is built)
# Params are:
# SRC_DIR - source dir
# DST_DIR - destination dir (Linux: ../share/metronomek)


SRC_DIR=$1
DST_DIR=$2

printf "\033[01;35mLinking source files necessary to run MetronomeK"
printf "\033[01;00m"
echo

if [ $( echo $DST_DIR| grep 'Resources')  ]; then
  echo "Linking for Mac Os"
  DST_DIR=$2/
  LINK_FROM=$2/../
else
  echo "Linking for Linux"
  DST_DIR=$2/share/metronomek/
  LINK_FROM=$2/
fi

echo $DST_DIR

if [ -d $DST_DIR ]; then
  echo "Already done... Exiting!"
  exit
else
  mkdir -p $DST_DIR
  ln -s $LINK_FROM/translations $DST_DIR
  ln -s $SRC_DIR/sounds $DST_DIR
fi

