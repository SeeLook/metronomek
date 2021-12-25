/** This file is part of Metronomek                                  *
 * Copyright (C) 2019-2021 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#ifndef TGLOB_H
#define TGLOB_H

#include <QtCore/qobject.h>
#include <QtCore/qrect.h>
#include <QtGui/qcolor.h>


class QSettings;

#define GLOB (Tglob::instance())


class Ttempo {

  Q_GADGET

  Q_PROPERTY(QString name READ name)
  Q_PROPERTY(int low READ low)
  Q_PROPERTY(int hi READ hi)
  Q_PROPERTY(int mid READ mid)

public:
  Ttempo() {}
  Ttempo(const QString& italianName, quint8 lowVal, quint8 hiVal) :
    m_name(italianName), m_low(lowVal), m_hi(hiVal) {}

  QString name() const { return m_name; }
  int low() const { return m_low; }
  int hi() const { return m_hi; }
  int mid() const { return low() + (hi() - low()) / 2; }

private:
  QString     m_name;
  quint8      m_low = 0;
  quint8      m_hi = 0;
};


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
  Q_PROPERTY(QString lang READ lang WRITE setLang NOTIFY langChanged)

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

  QString lang() const { return m_lang; }
  void setLang(const QString& l);

  Q_INVOKABLE int bound(int low, int val, int hi) { return qBound(low, val, hi); }
  Q_INVOKABLE qreal bound(qreal low, qreal val, qreal hi) { return qBound(low, val, hi); }

  Q_INVOKABLE QString TR(const QString& context, const QString& text, const QString& disambiguation = QString(), int n = -1);

  Q_INVOKABLE Ttempo tempoName(int id) { return m_tempoList[id]; }
  Q_INVOKABLE int temposCount() const { return m_tempoList.count(); }

  Q_INVOKABLE QColor alpha(const QColor& c, int a);
  Q_INVOKABLE int fontSize() const;

      /**
       * Returns randomized color, @p alpha is alpha level
       * @p level (220 by default) determines maximal value of color [0 - 255].
       * Using smaller value avoids generating dark colors
       */
  Q_INVOKABLE QColor randomColor(int alpha = 255, int level = 220);

      /**
       * Changes HSV value of given @p c @p QColor by @p off parameter.
       * If original value is less than @p 128 it increases by @p off or decreases if not
       */
  Q_INVOKABLE QColor valueColor(QColor c, int off = 20);

      /**
       * Calculates Y position of a logo letter on upper part of a arch
       */
  Q_INVOKABLE qreal logoLetterY(int letterNr, qreal r);
  Q_INVOKABLE QString aboutQt() const;

  Q_INVOKABLE QString version() const;
  Q_INVOKABLE bool isAndroid() {
#if defined (Q_OS_ANDROID)
    return true;
#else
    return false;
#endif
  }

#if defined (Q_OS_ANDROID)
  Q_INVOKABLE void keepScreenOn(bool on);
  Q_INVOKABLE void setDisableRotation(bool disRot);
  Q_INVOKABLE bool isKeepScreenOn() { return  m_keepScreenOn; }
  Q_INVOKABLE bool disableRotation() { return  m_disableRotation; }
  Q_INVOKABLE bool fullScreen() { return m_fullScreen; }
  Q_INVOKABLE void setFullScreen(bool fs) { m_fullScreen = fs; }
#endif

signals:
  void dummySignal();
  void countVisibleChanged();
  void stationaryChanged();
  void langChanged();

private:
  void createTempoList();

private:
  static Tglob       *m_instance;
  QSettings          *m_settings;
  QRect               m_geometry;
  bool                m_countVisible;
  bool                m_stationary;
  QString             m_lang;
#if defined (Q_OS_ANDROID)
  bool                m_keepScreenOn;
  bool                m_disableRotation;
  bool                m_fullScreen;
#endif
  QList<Ttempo>       m_tempoList;
};

#endif // TGLOB_H
