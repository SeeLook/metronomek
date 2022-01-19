/** This file is part of Metronomek                                  *
 * Copyright (C) 2019-2022 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#include "tglob.h"
#include "taudioout.h"

#include <QtGui/qguiapplication.h>
#include <QtGui/qicon.h>
#include <QtGui/qpalette.h>
#include <QtQml/qqmlapplicationengine.h>
#include <QtCore/qtimer.h>
#include <QtCore/qelapsedtimer.h>
#include <QtQml/qqmlcontext.h>
#include <QtCore/qtranslator.h>
#include <QtGui/qfontdatabase.h>
#include <QtCore/qloggingcategory.h>
#include <QtCore/qsettings.h>
#include <QtCore/qdebug.h>

#if !defined (Q_OS_ANDROID)
  #include <QtCore/qcommandlineparser.h>
#endif


int main(int argc, char *argv[])
{
  QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

// It mutes QML warnings about connections syntax introduced in Qt 5.15
// TODO when Qt version requirements will rise to 5.15 or above, change syntax and remove that
  QLoggingCategory::setFilterRules(QStringLiteral("qt.qml.connections=false"));

  QElapsedTimer startElapsed;
  startElapsed.start();

  auto app = new QGuiApplication(argc, argv);
  app->setWindowIcon(QIcon(QStringLiteral(":/metronomek.png")));

  auto glob = new Tglob();

#if defined (Q_OS_ANDROID)
  auto pal = qApp->palette();
  pal.setColor(QPalette::Active, QPalette::Highlight, QColor(0, 0x96, 0x88)); // Teal color for highlight #009688
  pal.setColor(QPalette::Active, QPalette::HighlightedText, QColor(0xff, 0xf4, 0x05)); // #fff405
  pal.setColor(QPalette::Active, QPalette::Shadow, QColor(90, 90, 90)); // Dark gray for shadow
  pal.setColor(QPalette::Active, QPalette::Button, QColor(240, 240, 240)); // Very light gray for button
  pal.setColor(QPalette::Active, QPalette::Mid, QColor(124, 124, 124));
  pal.setColor(QPalette::Active, QPalette::Window, QColor(250, 250, 250)); // Almost white for windows
  qApp->setPalette(pal);
#endif

#if defined (Q_OS_WIN)
  QSettings accent(QStringLiteral("HKEY_USERS\\.DEFAULT\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Accent"),
                   QSettings::NativeFormat);
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

#if defined (Q_OS_ANDROID)
  QLocale loc(GLOB->lang().isEmpty() ? QLocale::system().language() : QLocale(GLOB->lang()).language());
  QString p = QStringLiteral("assets:/translations/");
#elif defined (Q_OS_WIN)
  QLocale loc(GLOB->lang().isEmpty() ? QLocale::system().uiLanguages().first() : GLOB->lang());
  QString p = qApp->applicationDirPath() + QLatin1String("/translations/");
#elif defined (Q_OS_MAC)
  QLocale loc(GLOB->lang().isEmpty() ? QLocale::system().uiLanguages().first() : GLOB->lang());
  QString p = qApp->applicationDirPath() + QLatin1String("/../Resources/translations/");
#else
  QLocale loc(QLocale(GLOB->lang().isEmpty() ? qgetenv("LANG") : GLOB->lang()).language(),
              QLocale(GLOB->lang().isEmpty() ? qgetenv("LANG") : GLOB->lang()).country());
  QString p = qApp->applicationDirPath() + QLatin1String("/../share/metronomek/translations/");
#endif
  QLocale::setDefault(loc);

  QTranslator mTranslator;
  if (mTranslator.load(loc, QStringLiteral("metronomek_"), QString(), p))
    GLOB->setLangLoaded(app->installTranslator(&mTranslator));

  QFontDatabase fd;
  int fid = fd.addApplicationFont(QStringLiteral(":/metronomek.otf"));
  if (fid == -1) {
    qDebug() << "Can not load MetronomeK fonts!\n";
    return 111;
  }

  auto sound = new TaudioOUT();

  auto engine = new QQmlApplicationEngine();
  const QUrl url(QStringLiteral("qrc:/MainWindow.qml"));
  QObject::connect(engine, &QQmlApplicationEngine::objectCreated, app, [url](QObject *obj, const QUrl &objUrl) {
      if (!obj && url == objUrl)
          QCoreApplication::exit(-1);
  }, Qt::QueuedConnection);

  engine->rootContext()->setContextProperty(QStringLiteral("GLOB"), glob);
  engine->rootContext()->setContextProperty(QStringLiteral("SOUND"), sound);
  engine->load(url);

  qDebug() << "==== METRONOMEK LAUNCH TIME" << startElapsed.nsecsElapsed() / 1000000.0 << "[ms] ====";

#if !defined (Q_OS_ANDROID)
  if (argc > 1) {
    auto ext = app->arguments().last().right(4).toLower();
    if (ext == QLatin1String(".wav") || ext == QLatin1String(".raw")) {
        sound->importFromCommandline();
    } else {
        QCommandLineParser cmd;
        auto helpOpt = cmd.addHelpOption();

        cmd.addOptions({{ QStringLiteral("no-version"), QStringLiteral("Do not display app version.\n")}});

        cmd.addOptions({{QStringList() << QStringLiteral("noise-threshold") << QStringLiteral("t"),
                      QStringLiteral("Percentage value above which a word is detected in audio file.\n"),
                      QStringLiteral("1.2%")}});
#if defined (WITH_SOUNDTOUCH)
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

  delete engine;
  delete sound;
  delete glob;
  delete app;

  return execCode;
}
