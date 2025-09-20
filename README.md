# MetronomeK

<img src="resources/metronomek.png" width="20%" height="20%" />

Metronome that works and sounds similar to mechanical devices
but with all goods of computer program.

--------------------------

## Features:
  - natural (real audio) sounds
  - selectable beat and ring sounds (i.e.: real metronome, clapping, snapping, etc.)
  - programmable tempo changes (aka accelerando and rallentando)
  - possibility to change meter
  - visible and audible (verbal) counting
  - option to record own counting or download some already prepared
  - determining tempo BPM by tapping
  - cross-platform: Android, Linux, Mac, Windows
  - ... see [TODO](TODO.md) for more planed features

--------------------------

## Download and installation
**Binary packages**  (Linux AppImage, Mac Os dmg, Windows installer and Android apk)  
and **sources** are hosted  
 [at SourceForge](https://sourceforge.net/projects/metronomek/files/)
 [<img src="https://a.fsdn.com/con/app/sf-download-button" alt="SF" width="17%">](https://sourceforge.net/projects/metronomek/files/)

**Metronomek is also available at:**

  - [Google Play Store](https://play.google.com/store/apps/details?id=net.sf.metronomek)
    [<img src="https://play.google.com/intl/en_us/badges/images/generic/en_badge_web_generic.png"
    alt="Get it on Google Play"
    width="15%">](https://play.google.com/store/apps/details?id=net.sf.metronomek)

  - [Arch Linux (AUR)](https://aur.archlinux.org/packages/metronomek/)
    [<img src="https://upload.wikimedia.org/wikipedia/commons/a/a5/Archlinux-icon-crystal-64.svg" alt="AUR" width="5%">](https://aur.archlinux.org/packages/metronomek/)  
    ```
    yay -S metronomek
    ```

  - [Flatpak](https://flathub.org/apps/details/net.sf.metronomek)
    [<img src="https://flathub.org/assets/themes/flathub/flathub-logo-toolbar.svg"
    alt="Metronomek FlatPak"
    width="100">](https://flathub.org/apps/details/net.sf.metronomek)  
    ```
    flatpak install flathub net.sf.metronomek
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
