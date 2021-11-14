# Contributing to Metronomek

<br>

* **Calling bugs and issues**  
    Preferred way is to open issue through [OpenCode](https://www.opencode.net/seelook/metronomek/-/issues) or [GitHub](https://github.com/SeeLook/metronomek/issues).  
    However it requires to have account at any of those services. To call a bug anonymously use [SourceForge](https://sourceforge.net/p/metronomek/bugs/).

<br>

* **Translations**  
    This is very easy task, and doesn't require any extra computer skills.

    1. Download [metronomek_xx.ts file](https://www.opencode.net/seelook/metronomek/-/raw/master/translations/metronomek_xx.ts) and rename it apparently to your language, i.e: **metronomek_en.ts**

    2. Open this file in **Qt linguist** or any other application supported *.ts files.  
       Linux users can install it trough application manager of their distribution when Windows user may fetch it from [this repository](https://github.com/thurask/Qt-Linguist/releases/tag/20201205).

    3. Translation may be sent through [email](mailto:seelook@gmail.com), by opening [an issue](https://www.opencode.net/seelook/metronomek/-/issues) or by opening git pull request. As you like.

    4. To test the translations, generate (*release*) metronomek_en.qm file from Qt Linguist menu and put that file into *translations* folder where Metronomek is installed.  
       When Metronomek is an AppImage, unpack it first: `Metronomek-X.Y.Z.AppImage --appimage-extract`, *translations* folder will be in *usr/share/metronomek/*

<br>

* **Developing**  
  Planned features are put into [Road map](TODO.md) but any other reasonable ideas are welcome.  
  `C++` and `QML` languages are used, but to develop a new skin QML is quite enough.
