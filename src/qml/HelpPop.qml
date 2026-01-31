// SPDX-FileCopyrightText: 2022 Tomasz Bojczuk <seelook@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

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
        height: Math.min(contentHeight, Window.height * 0.75)
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
