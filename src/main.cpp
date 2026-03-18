// SPDX-FileCopyrightText: 2019-2026 Tomasz Bojczuk <seelook@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

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
#include <QtQuick/qquickwindow.h>

#if defined(Q_OS_ANDROID)
#include <QtGui/qguiapplication.h>
#include <QtGui/qstylehints.h>
#include <cstdlib>
#else
#include <QtCore/qcommandlineparser.h>
#include <QtWidgets/qapplication.h>
#endif

using namespace Qt::Literals::StringLiterals;

int main(int argc, char *argv[])
{
    QElapsedTimer startElapsed;
    startElapsed.start();

#if defined(Q_OS_ANDROID)
    QGuiApplication app(argc, argv);

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
    QApplication app(argc, argv);
    app.setWindowIcon(QIcon(u":/metronomek.png"_s));
#endif

    int fid = QFontDatabase::addApplicationFont(u":/metronomek.otf"_s);
    if (fid == -1) {
        qDebug() << "Can not load MetronomeK fonts!\n";
        return 111;
    }

    int execCode = 0;
    {
        QQmlApplicationEngine engine;

        engine.loadFromModule(u"Metronomek.Core"_s, u"MainWindow"_s);
        if (engine.rootObjects().isEmpty()) {
            return -1;
        }

        qDebug() << "==== METRONOMEK LAUNCH TIME" << startElapsed.nsecsElapsed() / 1000000.0 << "[ms] ====";

        SOUND->init();

#if !defined(Q_OS_ANDROID)
        if (argc > 1) {
            auto ext = app.arguments().last().right(4).toLower();
            if (ext == u".wav"_s || ext == u".raw"_s) {
                SOUND->importFromCommandline();
            } else {
                QCommandLineParser cmd;
                auto helpOpt = cmd.addHelpOption();

                cmd.addOptions({{u"no-version"_s, u"Do not display app version.\n"_s}});

                cmd.addOptions({{{u"noise-threshold"_s, u"t"_s}, u"Percentage value above which a word is detected in audio file.\n"_s, u"1.2%"_s}});
                cmd.addOptions({{{u"no-align"_s, u"a"_s},
                                 u"Do not align beginning audio data of counting."
                                 " By default it is done to keep their strongest part at the same position for all numerals.\n"_s}});
#if defined(WITH_SOUNDTOUCH)
                cmd.addOptions({{{u"shrink-counting"_s, u"s"_s}, u"Squash numeral audio data duration when it is too long (> 300ms).\n"_s, u"false"_s}});
#endif

                cmd.parse(app.arguments());
                if (cmd.isSet(helpOpt))
                    cmd.showHelp();
            }
        }
#endif

        execCode = app.exec();
    }

#if defined(Q_OS_ANDROID)
    std::_Exit(execCode);
#else
    return execCode;
#endif
}
