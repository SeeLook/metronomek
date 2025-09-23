/** This file is part of Metronomek                                  *
 * Copyright (C) 2022-2025 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

import QtQuick
import QtQuick.Controls

SidePop {
    id: countPop

    property CountManager cntMan: SOUND.countManager()
    property var langModel: cntMan.languagesModel()

    visible: true
    modal: true
    bgColor: Qt.tint(ActivPalette.window, GLOB.alpha(ActivPalette.highlight, 30))
    height: col.height + FM.height * 2
    Component.onCompleted: {
        var currL = cntMan.currentLanguage();
        for (var l = 0; l < langModel.length; ++l) {
            var lang = langModel[l].split(";");
            langList.append({
                "langName": lang[0],
                "langID": lang[1]
            });
            if (currL == lang[1])
                langCombo.currentIndex = l;

        }
    }

    ListModel {
        id: langList
    }

    Column {
        id: col

        x: (parent.width - width) / 2
        spacing: FM.height / 2

        TextField {
            id: cntName

            anchors.horizontalCenter: parent.horizontalCenter
            width: countPop.width - FM.height * 4
            placeholderText: qsTranslate("QDirModel", "Name")
            horizontalAlignment: TextInput.AlignHCenter
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: FM.height

            Text {
                id: lt

                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("language") + ":"
                color: ActivPalette.text
            }

            ComboBox {
                id: langCombo

                width: countPop.width - FM.height * 4 - lt.width
                model: langList
                textRole: "langName"
                valueRole: "langID"
                popup.width: GLOB.isAndroid() ? countPop.width - FM.height * 4 : langCombo.width
                popup.x: -FM.height * 4
            }

        }

        Text {
            width: countPop.width - 6 * FM.height
            color: ActivPalette.text
            wrapMode: Text.WordWrap
            text: qsTr("Please consider sharing this with others.")
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: FM.height

            Button {
                text: GLOB.TR("QPlatformTheme", "Save")
                onClicked: {
                    countPop.cntMan.storeCounting(langList.get(langCombo.currentIndex).langID, cntName.text);
                    countPop.close();
                }
            }

            Button {
                text: GLOB.TR("QPlatformTheme", "Cancel")
                onClicked: countPop.close()
            }

        }

    }

}
