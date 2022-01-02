#! /bin/bash


################################################################################
# Generates MetronomeK icons from svg to android/res source locations
# Obligatory call it from spare_parts location in the sources (exactly where it is)
################################################################################



inkscape -z icon.svg -w 36 -o ../installs/android/res/drawable-ldpi/icon.png
inkscape -z icon.svg -w 48 -o ../installs/android/res/drawable-mdpi/icon.png
inkscape -z icon.svg -w 72 -o ../installs/android/res/drawable-hdpi/icon.png
inkscape -z icon.svg -w 96 -o ../installs/android/res/drawable-xhdpi/icon.png
inkscape -z icon.svg -w 144 -o ../installs/android/res/drawable-xxhdpi/icon.png
inkscape -z icon.svg -w 196 -o ../installs/android/res/drawable-xxxhdpi/icon.png
