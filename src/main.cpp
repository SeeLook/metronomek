/** This file is part of Metronomek                                  *
 * Copyright (C) 2019-2020 by Tomasz Bojczuk (seelook@gmail.com)     *
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


int main(int argc, char *argv[])
{
  QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

  QElapsedTimer startElapsed;
  startElapsed.start();

  auto app = new QGuiApplication(argc, argv);
  app->setWindowIcon(QIcon(QStringLiteral(":/metronomek.png")));

#if defined (Q_OS_ANDROID)
  auto pal = qApp->palette();
  pal.setColor(QPalette::Active, QPalette::Highlight, QColor(0, 160, 160)); // Teal color for highlight for Android
  pal.setColor(QPalette::Active, QPalette::Shadow, QColor(90, 90, 90)); // Dark gray for shadow
  pal.setColor(QPalette::Active, QPalette::Button, QColor(189, 189, 189));
  pal.setColor(QPalette::Active, QPalette::Mid, QColor(124, 124, 124));
  qApp->setPalette(pal);
#endif

#if defined (Q_OS_ANDROID)
  QLocale loc(QLocale::system());
  QString p = QStringLiteral("assets:/translations/");
#elif defined (Q_OS_WIN)
  QLocale loc(QLocale::system().uiLanguages().first());
  QString p = qApp->applicationDirPath() + QLatin1String("/translations/");
#else
  QLocale loc(qgetenv("LANG"));
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

  auto glob = new Tglob();
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
