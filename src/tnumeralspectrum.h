/** This file is part of Metronomek                                  *
 * Copyright (C) 2022 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#ifndef TNUMERALSPECTRUM_H
#define TNUMERALSPECTRUM_H


#include <QtQuick/qquickpainteditem.h>


class TsoundData;


/**
 *
 */
class TnumeralSpectrum : public QQuickPaintedItem
{

  Q_OBJECT
  Q_PROPERTY(int nr READ nr WRITE setNr NOTIFY nrChanged)

public:
  explicit TnumeralSpectrum(QQuickItem* parent = nullptr);
  ~TnumeralSpectrum() override;

  int nr() const { return m_nr; }
  void setNr(int nr);

  void paint(QPainter* painter) override;

signals:
  void nrChanged(int nr);

private:
  int               m_nr = -1;
  TsoundData        *m_numData = nullptr;
};

#endif // TNUMERALSPECTRUM_H
