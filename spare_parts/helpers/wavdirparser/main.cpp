/** This file is part of Metronomek                                  *
 * Copyright (C) 2022 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


#include <QtCore/qcoreapplication.h>
#include <QtCore/qcommandlineparser.h>
#include <QtCore/qfile.h>
#include <QtCore/qfileinfo.h>
#include <QtCore/qdatastream.h>
#include <QtCore/qendian.h>
#include <QtCore/qxmlstream.h>
#include <QtCore/qlocale.h>

#include <QtCore/qdebug.h>


#define WAV_WAVE (1163280727) // 'WAVE'
#define WAV_FMT  (544501094)  // 'fmt '
#define WAV_DATA (1635017060) // 'data'
#define WAV_IXML (0x4c4d5869) // 'iXML'
#define WAV_BEXT (1954047330) // 'bext'


int main(int argc, char *argv[])
{

  QCoreApplication app(argc, argv);
  QString fileName;

  if (argc > 1) {
    QCommandLineParser cmd;
    cmd.setApplicationDescription(QStringLiteral("Dump XML data from given wav file and quit\n"));
    auto helpOpt = cmd.addHelpOption();

    cmd.process(app);
    if (cmd.isSet(helpOpt)) {
      cmd.showHelp();
      return 0;
    }

    fileName = app.arguments().last();
  }

  if (fileName.isEmpty())
    return 1;

  auto addr = QStringLiteral("https://sourceforge.net/projects/metronomek/files/counting/");

  QFile f(fileName);
  QString xml;
  if (f.exists() && f.open(QFile::ReadOnly)) {
    QDataStream in(&f);
    QString xmlString;
    quint32 header, chunkSize;
    in.skipRawData(8); // Ignore RIFF and all file size
    in >> header;
    header = qFromBigEndian<quint32>(header);
    if (header == WAV_WAVE) {
      in >> header;
      header = qFromBigEndian<quint32>(header);
      while (header != WAV_IXML) { // skip everything except iXML
        in >> chunkSize;
        chunkSize = qFromBigEndian<quint32>(chunkSize);
        in.skipRawData(chunkSize);
        if (in.atEnd()) {
            break;
        } else {
            in >> header;
            header = qFromBigEndian<quint32>(header);
        }
      }
      if (!in.atEnd() && header == WAV_IXML) {
        in.skipRawData(4); // iXML size
        in >> xmlString;
      }
    }
    f.close();
    if (!xmlString.isEmpty()) {
      QXmlStreamReader xml(xmlString);
      QLocale::Language lang = QLocale::C;
      QString cntText;
      while (xml.readNextStartElement()) {
        if (xml.name() == QLatin1String("verbalcount")) {
            lang = static_cast<QLocale::Language>(xml.attributes().value(QLatin1String("qtlang")).toInt());
            xml.skipCurrentElement();
        } else {
            xml.skipCurrentElement();
        }
      }
      if (lang == QLocale::C)
        return 1;
      QLocale l(lang);
      QFileInfo fi(fileName);
      auto fn = fi.fileName();
      auto out = QString("| %1 | %2 | %3 |").arg(l.name()).arg(l.languageToString(lang), -15, ' ').arg(l.nativeLanguageName(), -20, ' ');
      out += QString(" [%1](%2) | %3 KiB |").arg(fn).arg(addr + fn).arg(f.size() / 1024);

      qDebug().noquote() << out.toLocal8Bit();
    }
  }

  return 0;
}
