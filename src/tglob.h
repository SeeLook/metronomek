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
 * Globally available object with common properties and helpers.
 * It keeps @p QSettings instance accessible through @p settings()
 */
class Tglob : public QObject
{

  Q_OBJECT

  Q_PROPERTY(QRect geometry READ geometry WRITE setGeometry NOTIFY dummySignal)
  Q_PROPERTY(bool countVisible READ countVisible WRITE setCountVisible NOTIFY countVisibleChanged)
  Q_PROPERTY(bool stationary READ stationary WRITE setStationary NOTIFY stationaryChanged)

public:
  explicit Tglob(QObject *parent = nullptr);
  ~Tglob();

  static Tglob* instance() { return m_instance; }

  QSettings* settings() { return m_settings; }

  QRect geometry() const { return m_geometry; }
  void setGeometry(const QRect& g) { m_geometry = g; }

  bool countVisible() const { return m_countVisible; }
  void setCountVisible(bool cv);

  bool stationary() const { return m_stationary;}
  void setStationary(bool stat);

  Q_INVOKABLE QColor alpha(const QColor& c, int a);
  Q_INVOKABLE int fontSize() const;

      /**
       * Returns randomized color, @p alpha is alpha level
       * @p level (220 by default) determines maximal value of color [0 - 255].
       * Using smaller value avoids generating dark colors
       */
  Q_INVOKABLE QColor randomColor(int alpha = 255, int level = 220);

      /**
       * Calculates Y position of a logo letter on upper part of a arch
       */
  Q_INVOKABLE qreal logoLetterY(int letterNr, qreal r);

  Q_INVOKABLE bool isAndroid() {
#if defined (Q_OS_ANDROID)
    return true;
#else
    return false;
#endif
  }

signals:
  void dummySignal();
  void countVisibleChanged();
  void stationaryChanged();

private:
  static Tglob       *m_instance;
  QSettings          *m_settings;
  QRect               m_geometry;
  bool                m_countVisible;
  bool                m_stationary;
};

#endif // TGLOB_H
