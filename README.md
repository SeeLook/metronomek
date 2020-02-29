# MetronomeK

Metronome with trivial look but natural, high quality sounds and sophisticated possibilities

<img src="images/metronomek.png" width="20%" height="20%" />

Metronome that works and sounds similar to mechanical devices
but with all goods of computer program.

### Features:
  - selectable beat and ring sounds (i.e.: real metronome, clapping, snapping, etc.)
  - possibility to change meter
  - visible counting
  - determining tempo BPM by tapping
  - cross-platform: Android, Linux, Windows
  - ... see TODO for more planed features



## Building from sources

MetronomeK can be compiled with Qt framework [https://www.qt.io/](https://www.qt.io/)

To build the application perform (inside sources directory):

```
qmake metronomek.pro
make -jX # where X is number of CPU cores
```
To install it invoke

```
make install
```

to simply launch it where it was compiled

```
make runinplace
./src/metronomek
```
