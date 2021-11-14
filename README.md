# MetronomeK

<img src="images/metronomek.png" width="20%" height="20%" />

Metronome that works and sounds similar to mechanical devices
but with all goods of computer program.

--------------------------

## Features:
  - natural (real audio) sounds
  - selectable beat and ring sounds (i.e.: real metronome, clapping, snapping, etc.)
  - possibility to change meter
  - visible counting
  - determining tempo BPM by tapping
  - cross-platform: Android, Linux, Mac, Windows
  - ... see [TODO](TODO.md) for more planed features

--------------------------

## Download and installation
Binary packages (Linux AppImage, Mac Os dmg, Windows installer and Android apk)  
are hosted [at SourceForge](https://sourceforge.net/projects/metronomek/files/)

  - [Arch Linux (AUR)](https://aur.archlinux.org/packages/metronomek/)  
    ```
    yay -S metronomek
    ```

--------------------------
## Building from sources

**MetronomeK** can be compiled with Qt framework [https://www.qt.io/](https://www.qt.io/).

Under Linux, dev packages (with headers) of ALSA and/or PulseAudio are also required.

To build the application perform (inside sources directory):

```
$cmake .
$make -jX # where X is number of CPU cores
or
$ninja
```
To install it, invoke:

```
$make install
or
$ninja install
```

or, just to simply launch it where it was compiled without installation:

 - invoke once:

    ```
    $make runinplace
    or
    $ninja runinplace
    ```

 - and launch the app this way:

    ```
    $./src/metronomek
    ```
