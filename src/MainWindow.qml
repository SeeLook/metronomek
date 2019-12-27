/** This file is part of Metronomek                                  *
 * Copyright (C) 2019 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Shapes 1.12

import Metronomek 1.0

Window {
  id: mainWindow

  visible: true
  width: GLOB.geometry.width
  height: GLOB.geometry.height
  x: GLOB.geometry.x
  y: GLOB.geometry.y
  title: qsTr("MetronomeK") + " v0.3"
  color: activPal.base

  SystemPalette { id: activPal;  colorGroup: SystemPalette.Active }

  property bool leanEnough: false // pendulum is leaned out enough to start playing

  TmetroItem {
//     id: metro
    anchors.fill: parent

    Image {
      id: metro
      anchors.centerIn: parent
      source: "qrc:/bg.png"
      height: Math.min(parent.height, parent.width * 1.529564315352697)
      width: height * (sourceSize.width / sourceSize.height)

      MouseArea {
        id: stopArea
        enabled: SOUND.playing
        width: parent.width; height: parent.height * 0.5
        onPressAndHold: stopMetronome()
      }

      Rectangle {
        id: pendulum
        color: leanEnough ? "green" : (stopArea.containsPress && SOUND.playing ? "red" : (pendArea.dragged ? activPal.highlight : (GLOB.stationary ? "gray" : "black")))
        width: parent.width / 20; y: parent.height * 0.125 - width / 2
        x: parent.width * 0.3969; height: parent.height * 0.4572
        radius: width / 2
        transformOrigin: Item.Bottom

        MouseArea {
          id: pendArea
          property bool dragged: false
          enabled: !SOUND.playing
          width: parent.width * 3; height: parent.height; x: -parent.width
          cursorShape: dragged ? Qt.DragMoveCursor : Qt.ArrowCursor
          onPositionChanged: {
            dragged = true
            var dev = mouse.x - width / 2
            pendulum.rotation = (Math.atan(dev / height) * 180) / Math.PI
            leanEnough = Math.abs(dev) > height * 0.268 // 15 deg
          }
          onReleased: {
            leanEnough = false
            dragged = false
            if (Math.abs(mouse.x - width / 2) > height * 0.268)
              startMetronome()
            else
              stopMetronome()
          }
        }

        Shape {
          id: countW // counterweight
          width: parent.width * 3; height: parent.height / 5
          y: parent.height * (0.05 + ((SOUND.tempo - 40) / 200) * 0.6)
          anchors.horizontalCenter: parent.horizontalCenter
          ShapePath {
            strokeWidth: pendulum.width / 3
            strokeColor: countArea.containsPress ? activPal.highlight : "black"
            fillColor: "gray"
            capStyle: ShapePath.RoundCap; joinStyle: ShapePath.RoundJoin
            startX: 0; startY: 0
            PathLine { x: pendulum.width * 3; y: 0 }
            PathLine { x: pendulum.width * 3; y: pendulum.height / 5 }
            PathLine { x: pendulum.width * 2.5; y: pendulum.height / 4.2 }
            PathLine { x: pendulum.width * 0.5; y: pendulum.height / 4.2 }
            PathLine { x: 0; y: pendulum.height / 5 }
            PathLine { x: 0; y: 0 }
          }
          Text {
            visible: SOUND.meter > 1 && countChB.checked && SOUND.playing
            text: SOUND.meterCount + 1
            anchors.centerIn: parent
            color: "white"
            font { pixelSize: parent.height * 0.7; bold: true }
          }
          MouseArea {
            id: countArea
            enabled: !SOUND.playing || GLOB.stationary
            anchors.fill: parent
            drag.target: countW
            drag.axis: Drag.YAxis
            drag.minimumY: pendulum.height * 0.05; drag.maximumY: pendulum.height * 0.65
            cursorShape: drag.active ? Qt.DragMoveCursor : Qt.ArrowCursor
            onPositionChanged: SOUND.tempo = Math.round((countW.y * 200) / (pendulum.height * 0.6) + 23)
          }
        }
      }

      Rectangle { // cover for lover pendulum end
        color: "black"
        width: parent.width * 0.2; height: parent.width / 28
        x: parent.width * 0.3; y: parent.height * 0.555
      }

      Row {
        anchors { bottom: sb.top; right: sb.right }
        Label {
          text: qsTr("meter")
          anchors.verticalCenter: parent.verticalCenter
        }
        Tumbler {
          id: meterTumb
          width: metro.width * 0.2; height: width * 0.9
          model: 12
          wrap: false; visibleItemCount: 3
          currentIndex: SOUND.meter - 1
          onCurrentIndexChanged: SOUND.meter = currentIndex + 1
          delegate:  Label {
            text: index > 0 ? index + 1 : "X"
            opacity: 1.0 - Math.abs(Tumbler.displacement) / (Tumbler.tumbler.visibleItemCount / 2)
            horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
            height: meterTumb.height / 3
            font { pixelSize: height * 0.9; bold: true }
          }
        }
      }

      SpinBox {
        id: sb
        height: parent.height * 0.07; width: height * 3
        x: parent.width * 0.7 - width; y: parent.height * (GLOB.isAndroid() ? 0.85 : 0.88) - height
        font { bold: true; }
        from: 40; to: 240
        value: SOUND.tempo
        onValueModified: SOUND.tempo = value
      }

      Row {
        anchors { top: sb.bottom; right: sb.right }
        spacing: GLOB.fontSize() * 2
        CheckBox {
          id: countChB
          enabled: SOUND.meter > 1
          text: qsTr("count")
          checked: GLOB.countVisible
          onToggled: GLOB.countVisible = checked
        }
        CheckBox {
          id: bellChB
          enabled: SOUND.meter > 1
          text: qsTr("ring")
          checked: SOUND.ring
          onToggled: SOUND.ring = checked
        }
      }

      RoundButton {
        x: parent.width * 0.1; y: parent.height * 0.6
        width: metro.width * 0.15; height: width
        radius: width / 2
        onClicked: {
          if (SOUND.playing)
            stopMetronome()
          else
            startMetronome()
        }
        Rectangle {
          width: parent.height * 0.5; height: width
          anchors.centerIn: parent
          radius: SOUND.playing ? 0 : width / 2
          color: SOUND.playing ? "red" : "green"
        }
      }
    }
  }

  MainMenuButton { x: parent.width * 0.01; y: parent.height * 0.01}

  function startMetronome() {
    SOUND.meterCount = 0
    timer.toLeft = pendulum.rotation <= 0
    initAnim.to = GLOB.stationary ? 0 : (timer.toLeft ? -35 : 35)
    initAnim.duration = (30000 / SOUND.tempo) * ((35 - Math.abs(pendulum.rotation)) / 35)
    pendAnim.stop()
    initAnim.start()
  }

  function stopMetronome() {
    SOUND.playing = false;
    finishAnim.to = 0
    finishAnim.duration = (30000 / SOUND.tempo) * ((35 - Math.abs(pendulum.rotation)) / 35)
    pendAnim.stop()
    finishAnim.start()
  }

  NumberAnimation {
    id: pendAnim
    target: pendulum; property: "rotation"
    duration: 60000 / SOUND.tempo
  }

  NumberAnimation {
    id: initAnim
    target: pendulum; property: "rotation"
    onStopped: {
      timer.interval = 2 // delay to allow the timer react on starting sound signal
      SOUND.playing = true
    }
  }

  NumberAnimation {
    id: finishAnim
    target: pendulum; property: "rotation"
    to: 0
  }

  Timer {
    id: timer
    running: SOUND.playing && !GLOB.stationary
    repeat: true; triggeredOnStart: true
//     interval: 60000 / SOUND.tempo
    property real elap: 0
    property real lag: 0
    property bool toLeft: true
    onRunningChanged: {
      if (running) {
        elap = 0; lag = 0
      }
    }
    onTriggered: {
      pendAnim.stop()
      pendAnim.to = toLeft ? 35 : -35
      pendAnim.start()
      var currTime = new Date().getTime()
      if (elap > 0) {
        elap = currTime - elap
        lag += elap - interval
      }
      elap = currTime
      interval = Math.max((60000 / SOUND.tempo) - lag, 1)
      lag = 0
      toLeft = !toLeft
    }
  }

//   Component.onCompleted: {}

  onClosing: {
    GLOB.geometry = Qt.rect(x ,y, width, height)
  }
}
