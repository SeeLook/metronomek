/** This file is part of Metronomek                                  *
 * Copyright (C) 2019 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#include "tglob.h"

#include <QtCore/qsettings.h>
#include <QtGui/qguiapplication.h>
#include <QtGui/qfont.h>

#include "QtCore/qdebug.h"


Tglob* Tglob::m_instance = nullptr;


Tglob::Tglob(QObject *parent) :
  QObject(parent)
{
  m_instance = this;

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
}


Tglob::~Tglob()
{
#if !defined (Q_OS_ANDROID)
  m_settings->setValue(QStringLiteral("geometry"), m_geometry);
#endif
  m_settings->setValue(QStringLiteral("countVisible"), m_countVisible);
}


void Tglob::setCountVisible(bool cv) {
  if (cv != m_countVisible) {
    m_countVisible = cv;
    emit countVisibleChanged();
  }
}


QColor Tglob::alpha(const QColor& c, int a) {
  return QColor(c.red(), c.green(), c.blue(), a);
}


int Tglob::fontSize() const {
  return qApp->font().pixelSize() > 0 ? qApp->font().pixelSize() : qApp->font().pointSize();
}
