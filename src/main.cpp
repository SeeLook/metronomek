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
#include <QtGui/qstylehints.h>
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

    auto pal = qApp->palette();
    if (QNativeInterface::QAndroidApplication::sdkVersion() < 31) {
        pal.setColor(QPalette::Active, QPalette::Highlight, QColor(0, 0x96, 0x88)); // Teal color for highlight #009688
        pal.setColor(QPalette::Active, QPalette::HighlightedText, QColor(0xff, 0xf4, 0x05)); // #fff405
        pal.setColor(QPalette::Active, QPalette::Shadow, QColor(90, 90, 90)); // Dark gray for shadow
        pal.setColor(QPalette::Active, QPalette::Button, QColor(189, 189, 189));
        pal.setColor(QPalette::Active, QPalette::Mid, QColor(124, 124, 124));
        pal.setColor(QPalette::Active, QPalette::Base, QColor(220, 220, 220));
    }
    const bool isDark = QGuiApplication::styleHints()->colorScheme() == Qt::ColorScheme::Dark;
    pal.setColor(QPalette::Active, QPalette::AlternateBase, isDark ? pal.base().color().lighter(110) : pal.base().color().darker(110));
    qApp->setPalette(pal);
#else
    auto app = new QApplication(argc, argv);
    app->setWindowIcon(QIcon(QStringLiteral(":/metronomek.png")));
#endif

    int fid = QFontDatabase::addApplicationFont(QStringLiteral(":/metronomek.otf"));
    if (fid == -1) {
        qDebug() << "Can not load MetronomeK fonts!\n";
        delete app;
        return 111;
    }

    auto engine = new QQmlApplicationEngine();

    engine->loadFromModule("Metronomek.Core", u"MainWindow"_s);
    if (engine->rootObjects().isEmpty()) {
        delete app;
        return -1;
    }

    engine->setObjectOwnership(GLOB, QJSEngine::CppOwnership);
    engine->setObjectOwnership(SOUND, QJSEngine::CppOwnership);

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

    QObject::connect(app, &QCoreApplication::aboutToQuit, [&]() {
        QCoreApplication::processEvents(QEventLoop::AllEvents, 50);
        delete SOUND;
        delete GLOB;
    });

    // app->setQuitOnLastWindowClosed(true);
    int execCode = app->exec();

    delete engine;
    delete app;

    return execCode;
}
