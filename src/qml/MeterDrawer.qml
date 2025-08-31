/** This file is part of Metronomek                                  *
 * Copyright (C) 2019 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

import QtQuick
import QtQuick.Controls

Drawer {
    id: mDrawer

    edge: Qt.RightEdge
    width: fm.height * (GLOB.isAndroid() ? 4 : 5)
    height: mainWindow.height

    Column {
        width: parent.width

        Label {
            id: countText

            text: qsTranslate("MainWindow", "count to") + ":"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Repeater {
            model: 12

            Button {
                width: mDrawer.width
                height: (mainWindow.height - countText.height) / 12
                font.pixelSize: index > 0 ? height * 0.6 : height * 0.3
                flat: true
                text: index > 0 ? index + 1 : qsTr("none")
                checked: SOUND.meter === index + 1
                onClicked: {
                    SOUND.meter = index + 1;
                    mDrawer.close();
                }
                checkable: true
            }

        }

    }

}
