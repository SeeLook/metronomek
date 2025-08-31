/** This file is part of Metronomek                                  *
 * Copyright (C) 2022 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

import Metronomek.Core
import QtQuick
import QtQuick.Controls

// pragma ComponentBehavior: Bound

Tdialog {
    id: vCntPage

    // private
    property CountManager cntMan: SOUND.countManager()
    property var progBar: null
    property var actionsMenu: null

    function appendToLocalModel(modelEntry) {
        var wav = modelEntry.split(";");
        localCntsMod.append({
            "langID": wav[0],
            "langName": wav[1],
            "cntName": wav[2]
        });
    }

    function updateOnlineModel() {
        var oMod = cntMan.onlineModel();
        for (var w = 0; w < oMod.length; ++w) {
            var wav = oMod[w].split(";");
            onlineMod.append({
                "langID": wav[0],
                "langName": wav[1] + " / " + wav[2],
                "size": wav[3]
            });
        }
    }

    visible: true
    padding: GLOB.fontSize() / 4
    standardButtons: Dialog.Ok | Dialog.Help
    Component.onCompleted: {
        footer.standardButton(Dialog.Help).text = GLOB.TR("TempoPage", "Actions");
    }
    onHelpRequested: {
        if (!actionsMenu)
            actionsMenu = actMenuComp.createObject(mainWindow);

        actionsMenu.open();
    }

    Connections {
        target: cntMan
        function onAppendToLocalModel(modelEntry: string): void {
            appendToLocalModel(modelEntry);
            localList.positionViewAtEnd();
        }

        function onDownProgress(prog: real): void {
            progBar.indeterminate = false;
            progBar.value = prog;
            if (prog >= 1)
                progBar.destroy(1000);
            else if (prog < 0)
                progBar.destroy();
        }

        function onOnlineModelUpdated() {
            onlineList.model = null;
            onlineMod.clear();
            updateOnlineModel();
            onlineList.model = onlineMod;
            progBar.destroy();
        }
    }

    ListModel {
        id: localCntsMod
    }

    Column {
        ListView {
            id: localList

            width: vCntPage.width - GLOB.fontSize()
            height: Math.min(contentHeight, (vCntPage.height - vCntPage.implicitFooterHeight) / 2 - GLOB.fontSize() * 2)
            spacing: 1
            currentIndex: -1
            model: localCntsMod
            clip: true
            Component.onCompleted: {
                if (localCntsMod.count == 0) {
                    var wavMod = cntMan.countingModelLocal();
                    for (var w = 0; w < wavMod.length; ++w) appendToLocalModel(wavMod[w])
                    localList.positionViewAtIndex(cntMan.localModelId, ListView.Contain);
                }
            }

            header: Rectangle {
                width: parent.width
                height: fm.height * 1.5
                color: ActivPalette.text

                Text {
                    anchors.centerIn: parent
                    color: ActivPalette.base
                    text: qsTr("available sounds of counting")
                }

            }

            ScrollBar.vertical: ScrollBar {
            }

            delegate: DragDelegate {
                id: bgRect

                property var modelData: localCntsMod.get(index)

                dragEnabled: index > 0
                width: parent ? parent.width : 0
                height: fm.height * 3
                color: Qt.tint(index % 2 ? ActivPalette.base : ActivPalette.alternateBase, GLOB.alpha(toDel ? "red" : ActivPalette.highlight, pressed || containsMouse ? 50 : (cntMan?.localModelId === index ? 20 : 0)))
                onClicked: cntMan.localModelId = index
                onRemoved: {
                    cntMan.removeLocalWav(index);
                    localCntsMod.remove(index);
                }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: fm.height / 2

                    Rectangle {
                        width: fm.height * 4.5
                        height: bgRect.height
                        color: cntMan?.localModelId == index ? ActivPalette.highlight : "transparent"

                        Text {
                            anchors.centerIn: parent
                            color: cntMan?.localModelId == index ? ActivPalette.highlightedText : ActivPalette.text
                            text: modelData ? modelData.langID : ""

                            font {
                                bold: true
                            }

                        }

                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width: bgRect.width - fm.height * 5

                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            color: ActivPalette.text
                            text: modelData ? modelData.langName : ""
                            font.pixelSize: fm.height
                            minimumPixelSize: fm.height / 2
                            fontSizeMode: Text.HorizontalFit
                            elide: Text.ElideRight
                        }

                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            color: ActivPalette.text
                            text: modelData ? modelData.cntName : ""
                            font.pixelSize: fm.height * 1.1
                            minimumPixelSize: fm.height * 0.7
                            fontSizeMode: Text.HorizontalFit
                            elide: Text.ElideRight
                        }

                    }

                }

            }

        }

        Rectangle {
            width: vCntPage.width - GLOB.fontSize()
            height: fm.height / 2
            color: ActivPalette.text
        }

        ListModel {
            id: onlineMod
        }

        ListView {
            id: onlineList

            width: vCntPage.width - GLOB.fontSize()
            height: vCntPage.height - vCntPage.implicitFooterHeight - localList.height - fm.height
            spacing: 1
            clip: true
            currentIndex: -1
            model: onlineMod
            Component.onCompleted: {
                if (onlineMod.count == 0)
                    updateOnlineModel();

            }

            header: Rectangle {
                width: parent.width
                height: fm.height * 1.5
                color: ActivPalette.highlight

                Row {
                    anchors.centerIn: parent

                    Text {
                        color: ActivPalette.highlightedText
                        text: qsTr("sounds of counting to download")
                    }

                }

            }

            delegate: Rectangle {
                id: bgRect

                property var modelEntry: onlineMod.get(index)

                width: parent.width
                height: fm.height * 2.5
                color: ma.pressed || ma.containsMouse ? Qt.tint(ActivPalette.base, GLOB.alpha(ActivPalette.highlight, 50)) : (index % 2 ? ActivPalette.base : ActivPalette.alternateBase)

                Text {
                    x: fm.height / 2
                    anchors.verticalCenter: parent.verticalCenter
                    color: ActivPalette.text
                    text: modelEntry.langID

                    font {
                        bold: true
                    }

                }

                Text {
                    x: fm.height * 3.5
                    width: bgRect.width - fm.height * 9
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    anchors.verticalCenter: parent.verticalCenter
                    color: ActivPalette.text
                    text: modelEntry.langName
                }

                Row {
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        rightMargin: fm.height / 4
                    }

                    Text {
                        anchors.bottom: parent.bottom
                        color: ActivPalette.text
                        text: qsTranslate("QFileSystemModel", "%1 KB").arg(modelEntry.size) + " "
                    }

                    Text {
                        color: ActivPalette.highlight
                        text: "\u00c1"

                        font {
                            family: "Metronomek"
                            pixelSize: fm.height * 1.7
                        }

                    }

                }

                MouseArea {
                    id: ma

                    enabled: !cntMan?.downloading
                    anchors.fill: parent
                    hoverEnabled: !GLOB.isAndroid()
                    onClicked: {
                        cntMan.downloadCounting(index);
                        progBar = progBarComp.createObject(bgRect);
                    }
                }

            }

            ScrollBar.vertical: ScrollBar {
            }

        }

    }

    Component {
        id: progBarComp

        ProgressBar {
            width: parent.width - fm.height
            height: fm.height / 3
            z: 50000
            indeterminate: true

            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }

            CuteButton {
                visible: cntMan.downloading
                width: fm.height * 5
                height: fm.height * 2
                x: parent.width - fm.height * 5
                y: -fm.height * 2
                text: qsTranslate("QPlatformTheme", "Abort")
                bgColor: Qt.tint(ActivPalette.button, GLOB.alpha("red", 40))
                onClicked: cntMan.abortDownload()
            }

        }

    }

    Component {
        id: actMenuComp

        Menu {
            id: actMenu
            y: vCntPage.height - height - vCntPage.implicitFooterHeight
            x: (vCntPage.width - width) / 2
            Component.onCompleted: {
                var maxW = 0;
                for (var m = 0; m < count; ++m) maxW = Math.max(maxW, itemAt(m).width)
                width = Math.min(vCntPage.width - fm.height, maxW + fm.height * 2);
            }

            MenuItem {
                text: qsTr("Prepare own verbal counting")
                onTriggered: Qt.createComponent("Metronomek.Core", "VerbalCountEdit").createObject(mainWindow)
            }

            MenuItem {
                text: qsTr("Update online counting list")
                onTriggered: {
                    cntMan.downloadOnlineList();
                    progBar = progBarComp.createObject(vCntPage.contentItem);
                }
            }

            MenuItem {
                text: qsTranslate("QShortcut", "Help")
                onTriggered: {
                    let hPop = Qt.createComponent("Metronomek.Core", "HelpPop").createObject(mainWindow, {
                        "helpText": qsTr("Matronomek is installed with verbal counting only in English language.") + "<br>" + qsTr("But counting for other languages can be easy obtained:") + "<ul><li>" + qsTr("by downloading files available online (for free)") + "</li><li>" + qsTr("or by recording own counting.") + "</li></ul><br><a href=\"https://metronomek.sourceforge.io\">" + qsTr("Read more online.") + "</a>"
                    });
                    hPop.open();
                }
            }

        }

    }
}
