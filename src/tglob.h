/** This file is part of Metronomek                                  *
 * Copyright (C) 2019 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#ifndef TGLOB_H
#define TGLOB_H


#include <QtCore/qobject.h>
#include <QtCore/qrect.h>


class QSettings;


/**
 * 
 */
class Tglob : public QObject
{

  Q_OBJECT

  Q_PROPERTY(QRect geometry READ geometry WRITE setGeometry NOTIFY dummySignal)
  Q_PROPERTY(int tempo READ tempo WRITE setTempo NOTIFY tempoChanged)

public:
  explicit Tglob(QObject *parent = nullptr);
  ~Tglob();

  QRect geometry() const { return m_geometry; }
  void setGeometry(const QRect& g) { m_geometry = g; }
  int tempo() const { return m_tempo; }
  void setTempo(int t);

signals:
  void dummySignal();
  void tempoChanged();

private:
  QSettings          *m_settings;
  QRect               m_geometry;
  int                 m_tempo = 60;
};

#endif // TGLOB_H
