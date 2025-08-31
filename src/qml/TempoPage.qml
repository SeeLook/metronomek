/** This file is part of Metronomek                                  *
 * Copyright (C) 2021-2025 by Tomasz Bojczuk (seelook@gmail.com)    *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

import Metronomek.Core
import QtQuick
import QtQuick.Controls

Tdialog {
    // Dialog

    id: tempoPage

    // private
    property SpeedHandler speedHandler: null
    property ComboBox combo: null

    visible: true
    topPadding: GLOB.fontSize() / 2
    bottomPadding: GLOB.fontSize() / 2
    standardButtons: Dialog.Ok | Dialog.Help
    Component.onCompleted: {
        mainWindow.dialogItem = tempoPage;
        footer.standardButton(Dialog.Ok).text = qsTranslate("QPlatformTheme", "OK");
        footer.standardButton(Dialog.Help).text = qsTr("Actions");
        speedHandler = SOUND.speedHandler();
        speedHandler.emitAllTempos();
        combo.currentIndex = speedHandler.currCompId;
    }
    onHelpRequested: moreMenu.open()

    ListModel {
        id: tempoModel
    }

    ListView {
        //         onTextEdited: speedHandler.setTitle(text)

        id: changesList

        width: parent.width
        height: parent.height
        spacing: 1
        model: tempoModel

        header: ComboBox {
            id: comboEdit

            width: parent.width
            popup.contentItem.width: parent.width
            editable: true
            model: speedHandler ? speedHandler.compositions : null
            textRole: "title"
            Component.onCompleted: combo = this
            onActivated: (index) => {
                speedHandler.setComposition(index);
                displayText = currentText;
            }
            onAccepted: {
                displayText = editText;
                speedHandler.setTitle(editText);
            }

            contentItem: TextField {
                width: parent.width
                placeholderText: qsTr("Rhythmic Composition")
                text: comboEdit.displayText
                selectedTextColor: activPal.highlightedText
                selectionColor: activPal.highlight
                selectByMouse: true
            }

        }

        delegate: TempoPartDelegate {
            tp: modelData
            onClicked: {
                pop.tp = tp;
                if (pop.height < tempoPage.height / 2) {
                    var p = parent.mapToItem(tempoPage.contentItem, 0, y + height + fm.height / 2);
                    if (p.y > tempoPage.height - pop.height - fm.height / 2)
                        pop.y = p.y - pop.height - height - fm.height;
                    else
                        pop.y = p.y;
                    pop.x = (tempoPage.width - pop.width) / 2;
                }
                pop.open();
            }
        }

        footer: Column {
            width: parent.width
            spacing: fm.height / 2

            Button {
                width: parent.width
                text: qsTr("Add tempo change")
                onClicked: speedHandler.addTempo()
            }

            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                color: activPal.text
                wrapMode: Text.WordWrap
                text: qsTr("Tap or click to edit tempo change.") + "<br><font color=\"red\">" + qsTr("Drag the item left or right to remove it.")
            }

        }

    }

    Connections {
        function onAppendTempoChange(tp) {
            tempoModel.append({
                "tempoPart": tp
            });
        }

        function onRemoveTempoChange(tpId) {
            tempoModel.remove(tpId);
        }

        function onClearAllChanges() {
            tempoModel.clear();
        }

        target: speedHandler
    }

    Menu {
        id: moreMenu

        y: tempoPage.height - height - tempoPage.implicitFooterHeight

        MenuItem {
            text: qsTr("New composition")
            onClicked: {
                speedHandler.newComposition();
                combo.currentIndex = combo.count - 1;
            }
        }

        MenuItem {
            text: qsTr("Duplicate")
            onClicked: {
                speedHandler.duplicateComposition();
                combo.currentIndex = combo.count - 1;
            }
        }
        //MenuItem {

        //text: qsTranslate("QFileDialog", "Open")
        //}
        //MenuItem {
        //text: qsTranslate("QFileDialog", "Save As")
        //}
        MenuItem {
            text: qsTranslate("QPlatformTheme", "Reset")
            onClicked: {
                var c = changesList.count - 1;
                for (var t = c; t > 0; --t) {
                    var it = changesList.itemAtIndex(t);
                    it.toDel = false;
                    it.rmAnim.duration = 150 + (c - t) * 25;
                    it.rmAnim.to = -it.width;
                    it.rmAnim.start();
                }
                changesList.itemAtIndex(0).tp.reset();
                var titl = speedHandler.getTitle(combo.currentIndex + 1);
                speedHandler.setTitle(titl);
                combo.displayText = titl;
            }
        }

        MenuItem {
            text: qsTranslate("QFileDialog", "Remove")
            enabled: combo.count > 1
            onClicked: {
                speedHandler.removeComposition(false);
                combo.currentIndex = 0;
                combo.displayText = combo.currentText;
            }
        }

    }

    Dialog {
        id: pop

        property TempoPart tp: null
        property real extraH: topPadding + bottomPadding + implicitFooterHeight + implicitHeaderHeight

        height: Math.min(extraH + tCol.height, tempoPage.height)
        width: tCol.width + leftPadding + rightPadding
        title: pop.tp ? pop.tp.tempoText : ""
        standardButtons: Dialog.Ok
        Component.onCompleted: footer.standardButton(Dialog.Ok).text = qsTranslate("QPlatformTheme", "OK")

        Flickable {
            height: Math.min(tCol.height + fm.height, tempoPage.height - pop.extraH)
            width: tCol.width
            contentHeight: tCol.height
            contentWidth: tCol.width
            clip: true

            Column {
                id: tCol

                spacing: GLOB.fontSize() / (GLOB.isAndroid() ? 6 : 2)
                padding: GLOB.fontSize() / 4

                Grid {
                    columns: tempoPage.width < initCtrl.width + targetCtrl.width ? 1 : 2
                    spacing: GLOB.fontSize()
                    anchors.horizontalCenter: parent.horizontalCenter
                    z: 10

                    TempoEdit {
                        id: initCtrl

                        text: qsTr("initial tempo").replace(" ", "<br>")
                        tempo: pop.tp ? pop.tp.initTempo : 40
                        onTempoModified: (t) => {
                            if (pop.tp) {
                                pop.tp.initTempo = t;
                            }
                        }
                    }

                    TempoEdit {
                        id: targetCtrl

                        text: qsTr("target tempo").replace(" ", "<br>")
                        tempo: pop.tp ? pop.tp.targetTempo : 40
                        onTempoModified: (t) => {
                            if (pop.tp) {
                                pop.tp.targetTempo = t;
                            }
                        }
                    }

                }

                Row {
                    spacing: GLOB.fontSize()
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: qsTr("Meter")
                        color: activPal.text
                    }

                    SpinBox {
                        editable: true
                        anchors.verticalCenter: parent.verticalCenter
                        from: 1
                        to: 12
                        value: pop.tp ? pop.tp.meter : 4
                        onValueModified: pop.tp.meter = value
                    }

                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: GLOB.fontSize() * 2

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: qsTr("Duration")
                        color: activPal.text
                        font.bold: true
                    }

                    CheckBox {
                        id: infiChB

                        enabled: pop.tp && pop.tp.initTempo === pop.tp.targetTempo
                        anchors.verticalCenter: parent.verticalCenter
                        checked: pop.tp && pop.tp.infinite
                        onToggled: pop.tp.infinite = checked
                        text: qsTr("infinite")
                    }

                }

                Grid {
                    enabled: !infiChB.checked
                    spacing: GLOB.fontSize()
                    columns: tempoPage.width < barCol.width + beatCol.width + secCol.width ? 1 : 3
                    anchors.horizontalCenter: parent.horizontalCenter

                    Column {
                        id: barCol

                        SpinBox {
                            id: barsSpin

                            editable: true
                            anchors.horizontalCenter: parent.horizontalCenter
                            from: 1
                            to: 1000
                            value: pop.tp ? pop.tp.bars : 1
                            onValueModified: pop.tp.bars = value
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: GLOB.chopS(qsTr("bars", "", barsSpin.value), barsSpin.value)
                            color: enabled ? activPal.text : disblPal.text
                        }

                    }

                    Column {
                        id: beatCol

                        SpinBox {
                            id: beatsSpin

                            editable: true
                            anchors.horizontalCenter: parent.horizontalCenter
                            from: 1
                            to: 12000
                            value: pop.tp ? pop.tp.beats : 1
                            onValueModified: pop.tp.beats = value
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: GLOB.chopS(qsTr("beats", "", beatsSpin.value), beatsSpin.value)
                            color: enabled ? activPal.text : disblPal.text
                        }

                    }

                    Column {
                        id: secCol

                        SpinBox {
                            id: secSpin

                            editable: true
                            anchors.horizontalCenter: parent.horizontalCenter
                            from: 1
                            to: 3600
                            value: pop.tp ? pop.tp.seconds : 1
                            onValueModified: pop.tp.seconds = value
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: GLOB.chopS(qsTr("seconds", "", secSpin.value), secSpin.value)
                            color: enabled ? activPal.text : disblPal.text
                        }

                    }

                }

            }
            // Flickable

        }

        enter: Transition {
            NumberAnimation {
                property: "scale"
                from: 0
                to: 1
            }

        }

        exit: Transition {
            NumberAnimation {
                property: "scale"
                to: 0
            }

        }

    }

}
