/** This file is part of Metronomek                                  *
 * Copyright (C) 2021 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


import QtQuick 2.12
import QtQuick.Controls 2.12

Column {
  id: tc

  property alias text: text.text
  property int tempo: 60

  signal tempoModified()

  spacing: GLOB.fontSize()

  Row {
    id: tRow
    spacing: GLOB.fontSize()
    Text {
      id: text
      anchors.verticalCenter: parent.verticalCenter
      color: activPal.text
    }
    SpinBox {
      editable: true
      anchors.verticalCenter: parent.verticalCenter
      from: 40; to: 240
      value: tempo
      onValueModified: {
        tempo = value
        tc.tempoModified()
      }
    }
  }

  Slider {
    width: tRow.width
    from: 40; to: 240
    value: tempo
    onMoved: {
      tempo = value
      tc.tempoModified()
    }
  }
}
