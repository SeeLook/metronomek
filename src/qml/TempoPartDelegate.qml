/** This file is part of Metronomek                                  *
 * Copyright (C) 2021-2022 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

import Metronomek
import QtQuick

DragDelegate {
    id: tpDelegate

    property TempoPart tp: null
    property int nr: tp ? tp.nr + 1 : -1

    dragEnabled: tempoModel.count > 1
    width: parent ? parent.width : 0
    height: tCol ? tCol.height : 0
    color: pressed || containsMouse ? Qt.tint(activPal.base, GLOB.alpha(toDel ? "red" : activPal.highlight, 50)) : (nr % 2 ? activPal.base : activPal.alternateBase)
    onRemoved: speedHandler.removeTempo(tp.nr - 1)

    Column {
        id: tCol

        spacing: GLOB.fontSize() / 2
        padding: GLOB.fontSize() / 4
        width: parent.width - GLOB.fontSize()

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: tp ? tp.tempoText : ""
            color: activPal.text
        }

        Text {
            text: GLOB.TR("TempoPage", "Meter") + " (" + GLOB.TR("MainWindow", "count to") + "): " + "<b>" + (tp ? tp.meter : 4) + "</b>"
            color: activPal.text
        }

        Text {
            text: GLOB.TR("TempoPage", "Duration") + ": " + (tp && tp.infinite ? GLOB.TR("TempoPage", "infinite") : "<br>" + GLOB.chopS(qsTr("<b>%n</b> bars", "", tp ? tp.bars : 0), tp ? tp.bars : 0) + " = " + GLOB.chopS(qsTr("<b>%n</b> beats", "", tp ? tp.beats : 0), tp ? tp.beats : 0) + " = " + GLOB.chopS(qsTr("<b>%n</b> seconds", "", tp ? tp.seconds : 0), tp ? tp.seconds : 0))
            color: activPal.text
        }

    }

}
