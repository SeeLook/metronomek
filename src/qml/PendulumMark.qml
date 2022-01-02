/** This file is part of Metronomek                                  *
 * Copyright (C) 2021-2022 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

import QtQuick 2.12


Text {
  property var currComp: SOUND.speedHandler().currComp
  property var tp: currComp.getPart(partId)
  property bool rall: tp && tp.initTempo > tp.targetTempo

  rotation: rall ? 180 : 0; transformOrigin: Item.Center
  y: tp && visible ? parent.height * 0.65 * ((tp.targetTempo - 40) / 200) + (rall ? height / 2 : parent.height * 0.18 - height / 2) : 0
  font { family: "Metronomek"; pixelSize: parent.width }
  text: "\u00Be"; color: activPal.varTempo
  visible: SOUND.playing && tp && tp.initTempo !== tp.targetTempo
}
