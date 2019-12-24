/** This file is part of Metronomek                                  *
 * Copyright (C) 2019 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#include "tglob.h"

#include <QtCore/qsettings.h>
#include <QtCore/qcoreapplication.h>

#include "QtCore/qdebug.h"


Tglob::Tglob(QObject *parent) :
  QObject(parent)
{
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
  m_tempo = m_settings->value(QStringLiteral("tempo"), 60).toInt();
}


Tglob::~Tglob()
{
#if !defined (Q_OS_ANDROID)
  m_settings->setValue(QStringLiteral("geometry"), m_geometry);
#endif
  m_settings->setValue(QStringLiteral("tempo"), m_tempo);
}


void Tglob::setTempo(int t) {
  if (t != m_tempo) {
    m_tempo = t;
    emit tempoChanged();
  }
}


QColor Tglob::alpha(const QColor& c, int a) {
  return QColor(c.red(), c.green(), c.blue(), a);
}
