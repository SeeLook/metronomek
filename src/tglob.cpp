/** This file is part of Metronomek                                  *
 * Copyright (C) 2019-2025 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#include "tglob.h"
#include "metronomek_conf.h"

#if defined(Q_OS_ANDROID)
#include "tandroid.h"
#endif

#include <QtCore/qdir.h>
#include <QtCore/qmath.h>
#include <QtCore/qrandom.h>
#include <QtCore/qsettings.h>
#include <QtCore/qstandardpaths.h>
#include <QtCore/qtranslator.h>
#include <QtGui/qfont.h>
#include <QtGui/qguiapplication.h>
#include <QtQml/qqmlcontext.h>
#include <QtQml/qqmlengine.h>

#include "QtCore/qdebug.h"

Tglob *Tglob::m_instance = nullptr;

using namespace Qt::Literals::StringLiterals;

Tglob::Tglob(QObject *parent)
    : QObject(parent)
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

#if defined(Q_OS_ANDROID)
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
    m_lang = m_settings->value(QStringLiteral("language"), QString()).toString();

    qRegisterMetaType<Ttempo>();
    createTempoList();

    auto p = translationPath();
#if defined(Q_OS_ANDROID)
    QLocale loc(m_lang.isEmpty() ? QLocale::system().language() : QLocale(m_lang).language());
#elif defined(Q_OS_WIN)
    QLocale loc(m_lang.isEmpty() ? QLocale::system().uiLanguages().first() : m_lang);
#elif defined(Q_OS_MAC)
    QLocale loc(m_lang.isEmpty() ? QLocale::system().uiLanguages().first() : m_lang);
#else
    QLocale loc(QLocale(m_lang.isEmpty() ? qgetenv("LANG") : m_lang).language(), QLocale(m_lang.isEmpty() ? qgetenv("LANG") : m_lang).territory());
#endif
    QLocale::setDefault(loc);

    m_translator = new QTranslator(this);
    if (m_translator->load(loc, QStringLiteral("metronomek_"), QString(), p))
        GLOB->setLangLoaded(qApp->installTranslator(m_translator));
}

Tglob::~Tglob()
{
#if defined(Q_OS_ANDROID)
    m_settings->setValue(QStringLiteral("keepScreenOn"), m_keepScreenOn);
    m_settings->setValue(QStringLiteral("disableRotation"), m_disableRotation);
    m_settings->setValue(QStringLiteral("fullScreen"), m_fullScreen);
#else
    m_settings->setValue(QStringLiteral("geometry"), m_geometry);
#endif
    m_settings->setValue(QStringLiteral("countVisible"), m_countVisible);
    m_settings->setValue(QStringLiteral("pendulumStationary"), m_stationary);
    m_settings->setValue(QStringLiteral("language"), m_lang);
}

void Tglob::setCountVisible(bool cv)
{
    if (cv != m_countVisible) {
        m_countVisible = cv;
        emit countVisibleChanged();
    }
}

void Tglob::setStationary(bool stat)
{
    if (stat != m_stationary) {
        m_stationary = stat;
        emit stationaryChanged();
    }
}

void Tglob::setLang(const QString &l)
{
    if (l == m_lang)
        return;

    m_lang = l;
    QLocale loc(QLocale(m_lang).language(), QLocale(m_lang).territory());
    QString p = translationPath();
    qApp->removeTranslator(m_translator);
    if (m_translator->load(loc, QStringLiteral("metronomek_"), QString(), p))
        GLOB->setLangLoaded(qApp->installTranslator(m_translator));
    auto topEngine = QQmlEngine::contextForObject(this)->engine();
    if (topEngine)
        topEngine->retranslate();
    emit langChanged();
}

void Tglob::setDialogItem(QVariant dgIt)
{
    m_dialogItem = dgIt;
    emit dialogItemChanged();
}

QString Tglob::userLocalPath() const
{
#if defined(Q_OS_ANDROID)
    QString userPath = QStandardPaths::standardLocations(QStandardPaths::GenericConfigLocation).first();
#else
    QString userPath = QStandardPaths::standardLocations(QStandardPaths::GenericDataLocation).first();
#endif
    if (userPath.isEmpty()) {
        // TODO: Find another path or give some debug
    } else {
        userPath.append(QStringLiteral("/Metronomek"));
        QDir d(userPath);
        if (!d.exists())
            d.mkpath(QStringLiteral("."));
    }
    return userPath;
}

QString Tglob::soundsPath() const
{
#if defined(Q_OS_ANDROID)
    return QStringLiteral("assets:/sounds/");
#elif defined(Q_OS_WIN)
    return qApp->applicationDirPath() + QLatin1String("/sounds/");
#elif defined(Q_OS_MAC)
    return qApp->applicationDirPath() + QLatin1String("/../Resources/sounds/");
#else
    return qApp->applicationDirPath() + QLatin1String("/../share/metronomek/sounds/");
#endif
}

QString Tglob::translationPath() const
{
#if defined(Q_OS_ANDROID)
    return u"assets:/translations/"_s;
#elif defined(Q_OS_WIN)
    return qApp->applicationDirPath() + "/translations"_L1;
#elif defined(Q_OS_MAC)
    return qApp->applicationDirPath() + "/../Resources/translations/"_L1;
#else
    return qApp->applicationDirPath() + "/../share/metronomek/translations/"_L1;
#endif
}

QString Tglob::chopS(const QString &plural, int n)
{
    if (!m_langLoaded && n == 1)
        return plural.chopped(1);
    else
        return plural;
}

/** HACK:
 * wrapper of standard Qt @p QApplication::translate method
 * to avoid parsing texts by lupdate.
 * This way translations of Qt can be used without adding them to *.ts files.
 */
QString Tglob::TR(const QString &context, const QString &text, const QString &disambiguation, int n)
{
    return QGuiApplication::translate(qPrintable(context), qPrintable(text), qPrintable(disambiguation), n);
}

QColor Tglob::alpha(const QColor &c, int a)
{
    return QColor(c.red(), c.green(), c.blue(), a);
}

QColor Tglob::randomColor(int alpha, int level)
{
    auto g = QRandomGenerator::global();
    return QColor(g->bounded(level), g->bounded(level), g->bounded(level), alpha);
}

QColor Tglob::valueColor(QColor c, int off)
{
    if (off) {
        int h, s, v, a;
        c.getHsl(&h, &s, &v, &a);
        c.setHsl(h, s, v + (v < 128 ? off : -off), a);
    }
    return c;
}

qreal Tglob::logoLetterY(int letterNr, qreal r)
{
    qreal angle = qDegreesToRadians(100.0) / 9.0; // 9 - letters number - 1
    qreal off = qDegreesToRadians(-50.0);
    return r - qCos(off + letterNr * angle) * r;
}

int Tglob::fontSize() const
{
    return qApp->font().pixelSize() > 0 ? qApp->font().pixelSize() : qApp->font().pointSize();
}

QString Tglob::aboutQt() const
{
    return QGuiApplication::translate("QMessageBox", "<h3>About Qt</h3><p>This program uses Qt version %1.</p>")
        .arg(qVersion())
        .replace(QLatin1String("<p>"), QString())
        .replace(QLatin1String("</p>"), QString());
}

QString Tglob::version() const
{
    if (qApp->arguments().last().contains(QLatin1String("--no-version")))
        return QString();
    else
        return QString(METRONOMEK_VERSION);
}

void Tglob::setDisableRotation(bool disRot)
{
    if (disRot != m_disableRotation) {
#if defined(Q_OS_ANDROID)
        Tandroid::disableRotation(disRot);
#endif
        m_disableRotation = disRot;
    }
}

void Tglob::keepScreenOn(bool on)
{
    if (on != m_keepScreenOn) {
#if defined(Q_OS_ANDROID)
        Tandroid::keepScreenOn(on);
#endif
        m_keepScreenOn = on;
    }
}

void Tglob::createTempoList()
{
    m_tempoList << Ttempo(QStringLiteral("Grave"), 35, 43) << Ttempo(QStringLiteral("Largo"), 44, 49) << Ttempo(QStringLiteral("Lento"), 50, 54)
                << Ttempo(QStringLiteral("Larghetto"), 55, 59) << Ttempo(QStringLiteral("Adagio"), 60, 64) << Ttempo(QStringLiteral("Adagietto"), 65, 69)
                << Ttempo(QStringLiteral("Andante"), 70, 79) << Ttempo(QStringLiteral("Andantino"), 80, 87) << Ttempo(QStringLiteral("Maestoso"), 88, 94)
                << Ttempo(QStringLiteral("Moderato"), 95, 104) << Ttempo(QStringLiteral("Allegretto"), 105, 115) << Ttempo(QStringLiteral("Animato"), 116, 125)
                << Ttempo(QStringLiteral("Allegro"), 126, 137) << Ttempo(QStringLiteral("Allegro assai"), 138, 143)
                << Ttempo(QStringLiteral("Vivace"), 144, 164) << Ttempo(QStringLiteral("Allegro vivace"), 165, 180)
                << Ttempo(QStringLiteral("Presto"), 181, 200) << Ttempo(QStringLiteral("Prestissimo"), 201, 240);
}
