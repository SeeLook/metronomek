/** This file is part of Metronomek                                  *
 * Copyright (C) 2019-2022 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


import QtQuick 2.12
import QtQuick.Controls 2.12


Tdialog {
  id: infoPage

  leftPadding: GLOB.fontSize() / 2; rightPadding: GLOB.fontSize() / 2
  topPadding: 0; bottomPadding: GLOB.fontSize() / 2

  Logo {
    id: logo
    pauseDuration: 0
    anim.running: parent.visible
    anim.loops: 4
    anim.onFinished: animTimer.start()
    Timer {
      id: animTimer
      repeat: false
      interval: 4000
      onTriggered: logo.anim.start()
    }
  }

  Flickable {
    width: parent.width; height: infoPage.height - infoPage.topPadding * 2 - logo.height
    anchors.top: logo.bottom
    clip: true
    ScrollBar.vertical: ScrollBar { active: true; visible: true }
    contentWidth: parent.width; contentHeight: col.height + 4 * GLOB.fontSize()

    Column {
      id: col
      width: parent.width
      spacing: fm.height / 2

      LinkText {
        width: parent.width - fm.height
        anchors.horizontalCenter: parent.horizontalCenter
        textFormat: Text.StyledText
        text: "<br><a href=\"https://metronomek.sourceforge.io\">metronomek.sf.net</a>
        <br>Copyright © 2019-2022 Tomasz Bojczuk<br>
        <a href=\"mailto:seelook.gmail.com\">seelook@gmail.com</a><br><br>"
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
      }

      LinkText {
        width: parent.width - fm.height
        text: GLOB.aboutQt() + "<br><a href=\"https://qt.io\">https://qt.io</a><br>"
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
      }

      LinkText {
        width: parent.width - fm.height
        text: qsTr("Metronomek ticks and rings through<br><b>%1</b> library.")
                .arg(GLOB.isAndroid() ? "<a href=\"https://github.com/google/oboe\">Oboe</a>"
                : "<a href=\"https://www.music.mcgill.ca/~gary/rtaudio/index.html\">RtAudio</a>")
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
      }

      LinkText {
        width: parent.width - GLOB.fontSize()
        wrapMode: Text.WordWrap
        anchors.horizontalCenter: parent.horizontalCenter
        textFormat: Text.StyledText
        text: "<br><br>" + qsTr("This program is free software; you can redistribute it and/or modify
          it under the terms of the GNU General Public License as published by
          the Free Software Foundation; either version 3 of the License, or
          (at your option) any later version.<br><br>

          This program is distributed in the hope that it will be useful,
          but WITHOUT ANY WARRANTY; without even the implied warranty of
          MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
          GNU General Public License for more details.<br><br>

          You should have received a copy of the GNU General Public License
          along with this program; if not, write to the Free Software Foundation,
          Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA"
        + "<br><br><a href=\"https://www.gnu.org/licenses/gpl-3.0.html\">https://www.gnu.org/licenses/gpl-3.0.html</a><br><br>"
        )
        horizontalAlignment: Text.AlignJustify
      }

    }
  } // Flickable

  standardButtons: Dialog.Ok

  Component.onCompleted: {
    mainWindow.dialogItem = infoPage
    footer.standardButton(Dialog.Ok).text = qsTranslate("QPlatformTheme", "OK")
  }
}
