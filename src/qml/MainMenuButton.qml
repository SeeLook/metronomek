/** This file is part of Metronomek                                  *
 * Copyright (C) 2019-2025 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

import QtQuick
import QtQuick.Controls

AbstractButton {
    id: menuButt

    property var drawerContent: null

    height: parent.height / 12
    width: height * 0.4
    onClicked: {
        drawer.open();
    }

    Drawer {
        id: drawer

        width: Math.min(mainWindow.width * 0.7, fm.height * 20)
        height: mainWindow.height
        onAboutToShow: {
            mainWindow.stopMetronome();
            if (!drawerContent)
                drawerContent = Qt.createComponent("qrc:/MainDrawerContent.qml").createObject(drawer.contentItem);

        }
    }

    background: Rectangle {
        color: GLOB.alpha(activPal.text, pressed ? 120 : 30)
        radius: width / 4
    }

    contentItem: Column {
        width: parent.width
        spacing: height / 6.6666
        topPadding: spacing

        Rectangle {
            width: menuButt.width / 3
            height: width
            radius: width / 4
            anchors.horizontalCenter: parent.horizontalCenter
            color: SOUND.ring ? "red" : activPal.text
        }

        Rectangle {
            width: menuButt.width / 3
            height: width
            radius: width / 4
            anchors.horizontalCenter: parent.horizontalCenter
            color: GLOB.countVisible ? "yellow" : activPal.text
        }

        Rectangle {
            width: menuButt.width / 3
            height: width
            radius: width / 4
            anchors.horizontalCenter: parent.horizontalCenter
            color: GLOB.stationary ? activPal.text : "lime"
        }

    }

}
