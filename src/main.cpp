/** This file is part of Metronomek                                  *
 * Copyright (C) 2019 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#include "tmetroitem.h"
#include "taudioout.h"

#include <QtGui/qguiapplication.h>
#include <QtQml/qqmlapplicationengine.h>
#include <QtCore/qtimer.h>
#include <QtCore/qelapsedtimer.h>
#include <QtCore/qdebug.h>


int main(int argc, char *argv[])
{
  QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

  QElapsedTimer startElapsed;
  startElapsed.start();

  QGuiApplication app(argc, argv);

  auto sound = new TaudioOUT();

  QQmlApplicationEngine engine;
  const QUrl url(QStringLiteral("qrc:/main.qml"));
  QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                    &app, [url](QObject *obj, const QUrl &objUrl) {
      if (!obj && url == objUrl)
          QCoreApplication::exit(-1);
  }, Qt::QueuedConnection);

  qmlRegisterType<TmetroItem>("Metronomek", 1, 0, "TmetroItem");
  engine.load(url);

// #if defined (Q_OS_ANDROID)
  qDebug() << "METRONOMEK LAUNCH TIME" << startElapsed.nsecsElapsed() / 1000000.0 << " [ms]";
// #else
//   QTextStream o(stdout);
//   o << "\033[01;35m METRONOMEK launch time: " << startElapsed.nsecsElapsed() / 1000000.0 << " [ms]\033[01;00m\n";
// #endif

  QTimer::singleShot(500, [=]{
    sound->init();
    sound->play();
  });

  int execCode = app.exec();

  delete sound;

  return execCode;
}
