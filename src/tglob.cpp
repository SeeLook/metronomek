/** This file is part of Metronomek                                  *
 * Copyright (C) 2019 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#include "tglob.h"
#include "src/metronomek_conf.h"

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

#if !defined (Q_OS_ANDROID)
  m_geometry = m_settings->value(QStringLiteral("geometry"), QRect()).toRect();
  if (m_geometry.isNull())
    m_geometry.setSize(QSize(314, 480));
#endif
  m_countVisible = m_settings->value(QStringLiteral("countVisible"), false).toBool();
  m_stationary = m_settings->value(QStringLiteral("pendulumStationary"), false).toBool();


  qsrand(QDateTime::currentDateTimeUtc().toTime_t());
}


Tglob::~Tglob()
{
#if !defined (Q_OS_ANDROID)
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
