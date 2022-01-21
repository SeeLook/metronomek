/** This file is part of Metronomek                                  *
 * Copyright (C) 2022 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#include "tnumeralspectrum.h"
#include "tsound.h"
#include "tsounddata.h"

#include <QtGui/qpainter.h>
#include <QtGui/qguiapplication.h>
#include <QtGui/qpalette.h>
#include <QtCore/qmath.h>

#include <QtCore/qdebug.h>


TnumeralSpectrum::TnumeralSpectrum(QQuickItem* parent) :
  QQuickPaintedItem(parent)
{
  setAntialiasing(true);
  connect(qApp, &QGuiApplication::paletteChanged, this, [=]{ update(); });
}


TnumeralSpectrum::~TnumeralSpectrum()
{
}


void TnumeralSpectrum::setNr(int nr) {
  if (m_nr == nr)
      return;

  if (SOUND->numerals() && nr >= 0 && nr < 12) {
    m_numData = SOUND->numerals()->at(nr);
  }
  m_nr = nr;
  emit nrChanged(m_nr);
}


void TnumeralSpectrum::paint(QPainter* painter) {
  painter->setPen(qApp->palette().text().color());
  if (m_numData && m_numData->size() - m_numData->offset() > 0) {
    int samPerBar = 24000.0 / width();
    // 24000 - half of 48000 - means 500ms - this is how many audio data frames are previewed
    for (int b = 0 ; b < qCeil(width()); ++b) {
      qint16 max = -32768;
      for (int s = 0; s < samPerBar; ++s) {
        max = qMax(max, m_numData->sampleAt(b * samPerBar + s));
      }
      int h = qRound((max / 32768.0) * height());
      int y = qRound((height() - h) / 2.0);
      painter->drawLine(b, y, b, y + h);
    }
    QFont f = qApp->font();
    f.setPixelSize(height() / 8);
    painter->setFont(f);
    qreal w2by3 = width() * 0.666666666;
    if (m_nr == 0)
      painter->drawText(w2by3 + 5, height() / 7, QStringLiteral("300 ms"));
    painter->setPen(qApp->palette().highlight().color());
    painter->drawLine(w2by3, 0, w2by3, height());
  }
}
