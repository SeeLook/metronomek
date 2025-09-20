## 0.7.7 devel
  #### Verbal counting
    - Metronomek can tick with real words (numerals usually)
    - user may prepare its own audio file (wav) with counting and import it to the app
    - or record the words directly in the program
    - also verbal counting files in a few languages are available online
    - and can be downloaded from the application

  #### Added Netherland translation

  #### Use system dark theme colors
    - also respect Android accent color

  #### Ported to Qt 6
    - use newest version for Android builds

  #### Android
    - use Oboe low latency library for audio

------------------------------------------------------------

## 0.6.0

  #### Added programmable speed up & slow down (_accelerando_ and _rallentando_)
    - new settings page to manage tempo change(s)
    - list of tempo changes can be defined - kind of rhythmic composition
    - every change has initial and target tempos and its duration can be set in bars, beats or seconds
    - duration may be infinite, then popup appears to switch to the next tempo
    - changes set (composition) can be stored in XML file
    - and there is the list of compositions to select

  #### Avoid cracks and cuts when playing finishes
    - terminate playing only when audio data of entire beat was sent

  #### Many of visual improvements
    - keep main menu text visible - adjust font size to width or elide
    - color of switches in menu corresponds with color of the menu button dots
    - [Windows] use system accent color for highlight

------------------------------------------------------------

## 0.5.1

  #### [Linux] Fixed high CPU usage
    - occurred with PulseAudio when ticking has been stopped

  #### [Linux] Improved packaging
    - fixed and updated appdata description and links there

------------------------------------------------------------

## 0.5.0

  #### Implemented basic metronome functionality:
    - tempo change
    - changing meter
    - ringing at "one"
    - selecting beat and ring sounds

  #### Added settings page
    - selecting audio output device when a few is available
    - selecting application language
    - [Android] suppress rotation, keep screen on, full screen

  #### Visible texts prepared for translations
    - and translated to Polish language

  #### CD/CI scripts for automatic building
    - Linux AppImage
    - Mac Os bundle in dmg image
    - Windows installer
------------------------------------------------------------
