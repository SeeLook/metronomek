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
  pal.setColor(QPalette::Active, QPalette::Shadow, QColor(144, 144, 144)); // Dark gray for shadow
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

  auto sound = new TaudioOUT();
  auto glob = new Tglob();

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
