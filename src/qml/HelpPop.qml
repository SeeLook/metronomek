/** This file is part of Metronomek                                  *
 * Copyright (C) 2022 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

import QtQuick
import QtQuick.Controls

SidePop {
    id: hPop

    property alias helpText: hText.text

    modal: true
    bgColor: Qt.tint(ActivPalette.base, GLOB.alpha(ActivPalette.highlight, 50))
    height: hFlick.height + 2 * padding

    Flickable {
        id: hFlick

        clip: true
        width: hPop.width - 2 * hPop.padding
        height: Math.min(contentHeight, mainWindow.height * 0.75)
        x: (hPop.width - width) / 2
        contentWidth: width
        contentHeight: hText.height + FM.height

        LinkText {
            id: hText

            x: FM.height / 2
            width: parent.width - FM.height
            color: ActivPalette.text
            wrapMode: Text.WordWrap
        }

        ScrollBar.vertical: ScrollBar {}

    }

}
