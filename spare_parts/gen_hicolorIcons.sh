#! /bin/bash


################################################################################
# Generates MetronomeK mimetype icons from svg to Images/hicolor/ source location
# Obligatory call it from spare_parts location in the sources (exactly where it is)
################################################################################



inkscape -z icon.svg -w 16 -e ../Images/hicolor/16x16/apps/metronomek.png
inkscape -z icon.svg -w 24 -e ../Images/hicolor/24x24/apps/metronomek.png
inkscape -z icon.svg -w 32 -e ../Images/hicolor/32x32/apps/metronomek.png
inkscape -z icon.svg -w 48 -e ../Images/hicolor/48x48/apps/metronomek.png
inkscape -z icon.svg -w 64 -e ../Images/hicolor/64x64/apps/metronomek.png
inkscape -z icon.svg -w 128 -e ../Images/hicolor/128x128/apps/metronomek.png
inkscape -z icon.svg -w 256 -e ../Images/hicolor/256x256/apps/metronomek.png
