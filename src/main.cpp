/** This file is part of Metronomek                                  *
 * Copyright (C) 2019-2021 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#include "tglob.h"
#include "taudioout.h"

#include <QtGui/qguiapplication.h>
#include <QtGui/qicon.h>
#include <QtGui/qpalette.h>
#include <QtQml/qqmlapplicationengine.h>
#include <QtCore/qtimer.h>
#include <QtCore/qelapsedtimer.h>
#include <QtCore/qdebug.h>
#include <QtQml/qqmlcontext.h>
#include <QtCore/qtranslator.h>
#include <QtGui/qfontdatabase.h>
#include <QtCore/qloggingcategory.h>


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
  pal.setColor(QPalette::Active, QPalette::Shadow, Qt::lightGray);
  pal.setColor(QPalette::Active, QPalette::Shadow, QColor(90, 90, 90)); // Dark gray for shadow
  pal.setColor(QPalette::Active, QPalette::Button, QColor(189, 189, 189));
  pal.setColor(QPalette::Active, QPalette::Mid, QColor(124, 124, 124));
  qApp->setPalette(pal);
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
    app->installTranslator(&mTranslator);

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

  int execCode = app->exec();

  delete engine;
  delete sound;
  delete glob;
  delete app;

  return execCode;
}
