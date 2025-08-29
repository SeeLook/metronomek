/** This file is part of Metronomek                                  *
 * Copyright (C) 2022 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

import QtQuick
import QtQuick.Controls

Rectangle {
    id: dragDel

    property bool dragEnabled: true
    property int nr: -1
    property alias pressed: ma.pressed
    property alias containsMouse: ma.containsMouse
    property alias mouseArea: ma
    property alias rmAnim: rmAnim
    property bool wasDragged: false
    property bool toDel: Math.abs(x) > delText.width

    signal clicked()
    signal removed()

    color: ma.pressed || ma.containsMouse ? Qt.tint(activPal.base, GLOB.alpha(toDel ? "red" : activPal.highlight, 50)) : (nr % 2 ? activPal.base : activPal.alternateBase)

    Text {
        id: delText

        visible: toDel
        parent: dragDel.parent
        text: qsTranslate("QLineEdit", "Delete")
        y: dragDel.y + (dragDel.height - height) / 2
        x: dragDel.x > delText.width ? fm.height : dragDel.width - fm.height - width
        color: "red"
        font.bold: true
    }

    MouseArea {
        id: ma

        anchors.fill: parent
        hoverEnabled: !GLOB.isAndroid()
        drag.axis: Drag.XAxis
        drag.minimumX: -width / 3
        drag.maximumX: width / 3
        drag.target: dragEnabled ? parent : null
        onPressed: wasDragged = false
        onPositionChanged: {
            if (Math.abs(dragDel.x) > fm.height)
                wasDragged = true;

        }
        onReleased: {
            if (Math.abs(dragDel.x) > delText.width + fm.height) {
                rmAnim.to = dragDel.x > 0 ? dragDel.width : -dragDel.width;
                rmAnim.start();
            } else {
                backAnim.start();
                if (!wasDragged && Math.abs(dragDel.x) < fm.height)
                    dragDel.clicked();

            }
            wasDragged = false;
        }
    }

    NumberAnimation {
        id: backAnim

        target: dragDel
        property: "x"
        to: 0
    }

    NumberAnimation {
        id: rmAnim

        target: dragDel
        property: "x"
        onFinished: dragDel.removed()
    }

}
