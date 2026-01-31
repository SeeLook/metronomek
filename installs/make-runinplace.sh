#! /bin/bash

# SPDX-FileCopyrightText: 2019-2026 Tomasz Bojczuk <seelook@gmail.com>
# SPDX-License-Identifier: CC0-1.0

# This script creates links necessary to run MetronomeK without installation (in directory where it is built)
# Params are:
# SRC_DIR - source dir
# DST_DIR - destination dir (Linux: ../share/metronomek)


SRC_DIR=$1
DST_DIR=$2

printf "\033[01;35mLinking source files necessary to run MetronomeK"
printf "\033[01;00m"
echo

DST_DIR=$2/share/metronomek/

echo $DST_DIR
if [ -d $DST_DIR ]; then
    echo "Already done... Exiting!"
    exit
else
    mkdir -p $DST_DIR
    ln -s $PWD/translations $DST_DIR
    ln -s $SRC_DIR/sounds $DST_DIR
fi

