/** This file is part of Metronomek                                  *
 * Copyright (C) 2019-2025 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#include "tglob.h"
#include "tsound.h"

#include <QtCore/qdebug.h>
#include <QtCore/qelapsedtimer.h>
#include <QtCore/qloggingcategory.h>
#include <QtCore/qthread.h>
#include <QtCore/qtimer.h>
#include <QtGui/qfontdatabase.h>
#include <QtGui/qicon.h>
#include <QtGui/qpalette.h>
#include <QtQml/qqmlapplicationengine.h>
#include <QtQml/qqmlcontext.h>

#if defined(Q_OS_ANDROID)
#include <QtGui/qguiapplication.h>
#else
#include <QtCore/qcommandlineparser.h>
#include <QtWidgets/qapplication.h>
#endif

using namespace Qt::Literals::StringLiterals;

int main(int argc, char *argv[])
{
    // qputenv("QT_QUICK_CONTROLS_STYLE", "Basic"); // reset style environment var - other styles can cause crashes
    QElapsedTimer startElapsed;
    startElapsed.start();

#if defined(Q_OS_ANDROID)
    auto app = new QGuiApplication(argc, argv);
#else
    auto app = new QApplication(argc, argv);
    app->setWindowIcon(QIcon(QStringLiteral(":/metronomek.png")));
#endif

#if defined(Q_OS_WIN)
    QSettings accent(QStringLiteral("HKEY_USERS\\.DEFAULT\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Accent"), QSettings::NativeFormat);
    if (accent.contains(QLatin1String("StartColorMenu"))) {
        int color = accent.value(QLatin1String("StartColorMenu")).toInt();
        int r = color & 0xff;
        int g = (color >> 8) & 0xff;
        int b = (color >> 16) & 0xff;
        auto pal = qApp->palette();
        QColor c(r, g, b);
        pal.setColor(QPalette::Active, QPalette::Highlight, c.lighter(110));
        qApp->setPalette(pal);
    }
#endif

    int fid = QFontDatabase::addApplicationFont(QStringLiteral(":/metronomek.otf"));
    if (fid == -1) {
        qDebug() << "Can not load MetronomeK fonts!\n";
        return 111;
    }

    auto engine = new QQmlApplicationEngine();

    engine->loadFromModule("Metronomek.Core", u"MainWindow"_s);
    if (engine->rootObjects().isEmpty())
        return -1;

    qDebug() << "==== METRONOMEK LAUNCH TIME" << startElapsed.nsecsElapsed() / 1000000.0 << "[ms] ====";

    SOUND->init();

#if !defined(Q_OS_ANDROID)
    if (argc > 1) {
        auto ext = app->arguments().last().right(4).toLower();
        if (ext == QLatin1String(".wav") || ext == QLatin1String(".raw")) {
            SOUND->importFromCommandline();
        } else {
            QCommandLineParser cmd;
            auto helpOpt = cmd.addHelpOption();

            cmd.addOptions({{QStringLiteral("no-version"), QStringLiteral("Do not display app version.\n")}});

            cmd.addOptions({{QStringList() << QStringLiteral("noise-threshold") << QStringLiteral("t"),
                             QStringLiteral("Percentage value above which a word is detected in audio file.\n"),
                             QStringLiteral("1.2%")}});
            cmd.addOptions({{QStringList() << QStringLiteral("no-align") << QStringLiteral("a"),
                             QStringLiteral("Do not align beginning audio data of counting."
                                            " By default it is done to keep their strongest part at the same position for all numerals.\n")}});
#if defined(WITH_SOUNDTOUCH)
            cmd.addOptions({{QStringList() << QStringLiteral("shrink-counting") << QStringLiteral("s"),
                             QStringLiteral("Squash numeral audio data duration when it is too long (> 300ms).\n"),
                             QStringLiteral("false")}});
#endif

            cmd.parse(app->arguments());
            if (cmd.isSet(helpOpt))
                cmd.showHelp();
        }
    }
#endif

    int execCode = app->exec();

    delete SOUND;
    QThread::currentThread()->msleep(200);
    delete GLOB;
    engine->deleteLater();
    delete app;

    return execCode;
}
