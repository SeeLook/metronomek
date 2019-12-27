/** This file is part of Metronomek                                  *
 * Copyright (C) 2019 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#ifndef TGLOB_H
#define TGLOB_H


#include <QtCore/qobject.h>
#include <QtCore/qrect.h>
#include <QtGui/qcolor.h>


class QSettings;

#define GLOB (Tglob::instance())


/**
 * 
 */
class Tglob : public QObject
{

  Q_OBJECT

  Q_PROPERTY(QRect geometry READ geometry WRITE setGeometry NOTIFY dummySignal)
  Q_PROPERTY(int tempo READ tempo WRITE setTempo NOTIFY tempoChanged)
  Q_PROPERTY(bool countVisible READ countVisible WRITE setCountVisible NOTIFY countVisibleChanged)

public:
  explicit Tglob(QObject *parent = nullptr);
  ~Tglob();

  static Tglob* instance() { return m_instance; }

  QSettings* settings() { return m_settings; }

  QRect geometry() const { return m_geometry; }
  void setGeometry(const QRect& g) { m_geometry = g; }

  int tempo() const { return m_tempo; }
  void setTempo(int t);

  bool countVisible() const { return m_countVisible; }
  void setCountVisible(bool cv);

  Q_INVOKABLE QColor alpha(const QColor& c, int a);
  Q_INVOKABLE int fontSize() const;

signals:
  void dummySignal();
  void tempoChanged();
  void countVisibleChanged();

private:
  static Tglob       *m_instance;
  QSettings          *m_settings;
  QRect               m_geometry;
  int                 m_tempo = 60;
  bool                m_countVisible;
};

#endif // TGLOB_H
