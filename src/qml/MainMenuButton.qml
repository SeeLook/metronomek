// SPDX-FileCopyrightText: 2019-2026 Tomasz Bojczuk <seelook@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Controls

AbstractButton {
    id: menuButt

    property var drawerContent: null
    property Window mWindow

    height: parent.height / 6
    width: height * 0.4
    onClicked: {
        drawer.open();
    }

    Drawer {
        id: drawer

        parent: menuButt.mWindow.contentItem
        width: Math.min(Math.min(menuButt.mWindow.width, menuButt.mWindow.height) * 0.7, FM.height * 20)
        height: menuButt.mWindow.height
        background: Background {}
        onAboutToShow: {
            (menuButt.mWindow as MainWindow).stopMetronome();
            if (!menuButt.drawerContent)
                menuButt.drawerContent = Qt.createComponent("Metronomek.Core", "MainDrawerContent").createObject(drawer.contentItem);
        }
    }

    background: Rectangle {
        width: menuButt.height
        height: width
        x: -height * 0.65
        y: -height * 0.35
        color: GLOB.alpha(ActivPalette.text, menuButt.pressed ? 120 : 30)
        radius: height / 2
    }

    contentItem: Column {
        width: parent.width / 2
        spacing: height / 12
        topPadding: spacing

        Rectangle {
            width: menuButt.width / 6
            height: width
            radius: width / 4
            anchors.horizontalCenter: parent.horizontalCenter
            color: SOUND.ring ? "red" : ActivPalette.text
        }

        Rectangle {
            width: menuButt.width / 6
            height: width
            radius: width / 4
            anchors.horizontalCenter: parent.horizontalCenter
            color: GLOB.countVisible ? "yellow" : ActivPalette.text
        }

        Rectangle {
            width: menuButt.width / 6
            height: width
            radius: width / 4
            anchors.horizontalCenter: parent.horizontalCenter
            color: GLOB.stationary ? ActivPalette.text : "lime"
        }
    }
}
