/** This file is part of Metronomek                                  *
 * Copyright (C) 2019-2021 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


import QtQuick
import QtQuick.Controls


Dialog {
  id: infoPage

  Logo {
    id: logo
    pauseDuration: 0
    anim.running: parent.visible
  }

  Flickable {
    width: parent.width; height: parent.height - logo.height
    anchors.top: logo.bottom
    clip: true
    ScrollBar.vertical: ScrollBar { active: true; visible: true }
    contentWidth: parent.width; contentHeight: col.height

    Column {
      id: col
      width: parent.width
      spacing: fm.height / 2

      LinkText {
        text: "<br><br>" + GLOB.aboutQt() + "<br><a href=\"https://qt.io\">https://qt.io</a>"
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
      }

      LinkText {
        anchors.horizontalCenter: parent.horizontalCenter
        textFormat: Text.StyledText
        text: "<br><br>Copyright © 2019-2020 Tomasz Bojczuk<br>
        <a href=\"mailto:seelook.gmail.com\">seelook@gmail.com</a><br><br>"
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
      }

      LinkText {
        width: parent.width
        wrapMode: Text.WordWrap
        anchors.horizontalCenter: parent.horizontalCenter
        textFormat: Text.StyledText
        text: qsTr("This program is free software; you can redistribute it and/or modify
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

  onVisibleChanged: {
    if (!visible)
      destroy()
  }

  Component.onCompleted: mainWindow.dialogItem = infoPage
}
