/** This file is part of Metronomek                                  *
 * Copyright (C) 2019 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#include "tglob.h"
#include "src/metronomek_conf.h"

#if defined (Q_OS_ANDROID)
  #include "android/tandroid.h"
#endif

#include <QtCore/qsettings.h>
#include <QtCore/qdatetime.h>
#include <QtCore/qmath.h>
#include <QtGui/qguiapplication.h>
#include <QtGui/qfont.h>

#include "QtCore/qdebug.h"


Tglob* Tglob::m_instance = nullptr;


Tglob::Tglob(QObject *parent) :
  QObject(parent)
{
  m_instance = this;

  qDebug() << "Metronomek version:" << METRONOMEK_VERSION;

  QCoreApplication::setOrganizationName(QStringLiteral("Metronomek"));
  QCoreApplication::setOrganizationDomain(QStringLiteral("metronomek.seelook.org"));
  QCoreApplication::setApplicationName(QStringLiteral("Metronomek"));
#if defined(Q_OS_WIN) || defined(Q_OS_MAC)
  m_settings = new QSettings(QSettings::IniFormat, QSettings::UserScope, QStringLiteral("Metronomek"), qApp->applicationName(), this);
#else
  m_settings = new QSettings(this);
#endif

#if defined (Q_OS_ANDROID)
  m_keepScreenOn = m_settings->value(QStringLiteral("keepScreenOn"), false).toBool();
  m_disableRotation = m_settings->value(QStringLiteral("disableRotation"), true).toBool();
  m_fullScreen = m_settings->value(QStringLiteral("fullScreen"), false).toBool();
  Tandroid::keepScreenOn(m_keepScreenOn);
  Tandroid::disableRotation(m_disableRotation);
#else
  m_geometry = m_settings->value(QStringLiteral("geometry"), QRect()).toRect();
  if (m_geometry.isNull())
    m_geometry.setSize(QSize(314, 480));
#endif
  m_countVisible = m_settings->value(QStringLiteral("countVisible"), false).toBool();
  m_stationary = m_settings->value(QStringLiteral("pendulumStationary"), false).toBool();

  qsrand(QDateTime::currentDateTimeUtc().toTime_t());

  qRegisterMetaType<Ttempo>();
  createTempoList();
}


Tglob::~Tglob()
{
#if defined (Q_OS_ANDROID)
  m_settings->setValue(QStringLiteral("keepScreenOn"), m_keepScreenOn);
  m_settings->setValue(QStringLiteral("disableRotation"), m_disableRotation);
  m_settings->setValue(QStringLiteral("fullScreen"), m_fullScreen);
#else
  m_settings->setValue(QStringLiteral("geometry"), m_geometry);
#endif
  m_settings->setValue(QStringLiteral("countVisible"), m_countVisible);
  m_settings->setValue(QStringLiteral("pendulumStationary"), m_stationary);
}


void Tglob::setCountVisible(bool cv) {
  if (cv != m_countVisible) {
    m_countVisible = cv;
    emit countVisibleChanged();
  }
}


void Tglob::setStationary(bool stat) {
  if (stat != m_stationary) {
    m_stationary = stat;
    emit stationaryChanged();
  }
}


QColor Tglob::alpha(const QColor& c, int a) {
  return QColor(c.red(), c.green(), c.blue(), a);
}


QColor Tglob::randomColor(int alpha, int level) {
  return QColor(qrand() % level, qrand() % level, qrand() % level, alpha);
}


qreal Tglob::logoLetterY(int letterNr, qreal r) {
  qreal angle = qDegreesToRadians(100.0) / 9.0; // 9 - letters number - 1
  qreal off = qDegreesToRadians(-50.0);
  return r - qCos(off + letterNr * angle) * r;
}


int Tglob::fontSize() const {
  return qApp->font().pixelSize() > 0 ? qApp->font().pixelSize() : qApp->font().pointSize();
}


QString Tglob::aboutQt() const {
  return QGuiApplication::translate("QMessageBox", "<h3>About Qt</h3><p>This program uses Qt version %1.</p>").arg(qVersion())
  .replace(QLatin1String("<p>"), QString()).replace(QLatin1String("</p>"), QString());
}


QString Tglob::version() const {
  return QString(METRONOMEK_VERSION);
}


#if defined (Q_OS_ANDROID)

void Tglob::setDisableRotation(bool disRot) {
  if (disRot != m_disableRotation) {
    Tandroid::disableRotation(disRot);
    m_disableRotation = disRot;
  }
}


void Tglob::keepScreenOn(bool on) {
  if (on != m_keepScreenOn) {
    Tandroid::keepScreenOn(on);
    m_keepScreenOn = on;
  }
}

#endif


/**
 * === from wikipedia
 * Grave – very slow (25–45 bpm)
 * Largo – broadly (40–60 bpm)
 * Lento – slowly (45–60 bpm)
 * Larghetto – rather broadly (60–66 bpm)
 * Adagio – slowly with great expression[9] (66–76 bpm)
 * Adagietto – slower than andante (72–76 bpm) or slightly faster than adagio (70–80 bpm)
 * Andante – at a walking pace (76–108 bpm)
 * Andantino – slightly faster than andante (although, in some cases, it can be taken to mean slightly slower than andante) (80–108 bpm)
 * Marcia moderato – moderately, in the manner of a march[10][11] (83–85 bpm)
 * Andante moderato – between andante and moderato (thus the name) (92–112 bpm)
 * Moderato – at a moderate speed (108–120 bpm)
 * Allegretto – by the mid-19th century, moderately fast (112–120 bpm); see paragraph above for earlier usage
 * Allegro moderato – close to, but not quite allegro (116–120 bpm)
 * Allegro – fast, quickly, and bright (120–156 bpm) (molto allegro is slightly faster than allegro, but always in its range)
 * Vivace – lively and fast (156–176 bpm)
 * Vivacissimo – very fast and lively (172–176 bpm)
 * Allegrissimo or Allegro vivace – very fast (172–176 bpm)
 * Presto – very, very fast (168–200 bpm)
 * Prestissimo – even faster than presto (200 bpm and over)
 */
void Tglob::createTempoList() {
  m_tempoList << Ttempo(QStringLiteral("Grave"), 35, 43)
              << Ttempo(QStringLiteral("Largo"), 44, 49)
              << Ttempo(QStringLiteral("Lento"), 50, 54)
              << Ttempo(QStringLiteral("Larghetto"), 55, 59)
              << Ttempo(QStringLiteral("Adagio"),  60, 64)
              << Ttempo(QStringLiteral("Adagietto"),  65, 69)
              << Ttempo(QStringLiteral("Andante"), 70, 79)
              << Ttempo(QStringLiteral("Andantino"), 80, 89)
              << Ttempo(QStringLiteral("Moderato"), 90, 104)
              << Ttempo(QStringLiteral("Allegretto"), 105, 115)
              << Ttempo(QStringLiteral("Allegro moderato"), 116, 125)
              << Ttempo(QStringLiteral("Allegro"), 126, 137)
              << Ttempo(QStringLiteral("Allegro assai"), 138, 143)
              << Ttempo(QStringLiteral("Allegro vivace"), 144, 159)
              << Ttempo(QStringLiteral("Vivace"), 160, 180)
              << Ttempo(QStringLiteral("Presto"), 181, 200)
              << Ttempo(QStringLiteral("Prestissimo"), 201, 240);
}
