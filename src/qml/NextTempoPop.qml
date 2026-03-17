// SPDX-FileCopyrightText: 2021-2026 Tomasz Bojczuk <seelook@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick

SidePop {
    id: nextPop

    bgColor: ActivPalette.varTempo
    focus: true

    Text {
        id: nextText

        x: (parent.width - width) / 2
        scale: (nextPop.width - FM.height * 4) / width
        transformOrigin: Item.Top
        color: ActivPalette.tempoText
        style: Text.Outline
        styleColor: ActivPalette.base
        text: qsTr("Next tempo")
    }

    Text {
        x: (parent.width - width) / 2
        y: nextText.height * nextText.scale
        width: nextText.width * nextText.scale
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        color: ActivPalette.tempoText
        style: Text.Outline
        styleColor: ActivPalette.base
        text: qsTr("Tap, click or press any key.")
    }

    MouseArea {
        width: parent.width
        height: parent.height
        onClicked: nextPop.close()
        focus: true
        Keys.onPressed: nextPop.close()
    }
}
