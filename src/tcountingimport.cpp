/** This file is part of Metronomek                                  *
 * Copyright (C) 2022 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */


#include "tcountingimport.h"
#include "tsounddata.h"

#include <QtCore/qcommandlineparser.h>
#include <QtCore/qfile.h>
#include <QtCore/qdatastream.h>
#include <QtCore/qendian.h>
#include <QtGui/qguiapplication.h>

#include <QtCore/qdebug.h>


TcountingImport::TcountingImport(QVector<TsoundData*>* numList, QObject* parent) :
  QObject(parent),
  m_numerals(numList)
{
}


void TcountingImport::importFromCommandline() {
  int noiseThreshold = 400;
  QCommandLineParser cmd;
  QCommandLineOption noiseThresholdOpt(QStringList() << QStringLiteral("noise-threshold") << QStringLiteral("t"),
                              QStringLiteral("\n"),
                              QStringLiteral("%"));
  cmd.addOption(noiseThresholdOpt);
  cmd.parse(qApp->arguments());
  if (cmd.isSet(noiseThresholdOpt))
    noiseThreshold = qRound((cmd.value(noiseThresholdOpt).toDouble() * 32768.0) / 100.0);
  importFormFile(qApp->arguments().last(), noiseThreshold);
}


void TcountingImport::importFormFile(const QString& fileName, int noiseThreshold) {
  qDebug() << "[TcountingImport] Importing from" << fileName << "threshold" << noiseThreshold;

  QFile audioF(fileName);
  if (!audioF.exists()) {
    qDebug() << "[TcountingImport] File doesn't exist!" << fileName;
    return;
  }

  quint32          sampleRate = 48000;
  int              frames;
  qint16*          data;
  bool             ok = true;

// Read audio data from file into data array
  if (audioF.open(QIODevice::ReadOnly)) {
      QDataStream      in;
      quint16          channelsNr = 1;

      auto ext = qApp->arguments().last().right(3).toLower();
      if (ext == QLatin1String("wav")) {
          in.setDevice(&audioF);
          qint32 headChunk;
          in >> headChunk;
          headChunk = qFromBigEndian<qint32>(headChunk);

          quint32 chunkSize;
          in >> chunkSize;
          chunkSize = qFromBigEndian<quint32>(chunkSize);
          in >> headChunk;
          headChunk = qFromBigEndian<qint32>(headChunk);

          if (headChunk == 1163280727) { // 1163280727 is 'value' of 'WAVE' text in valid WAV file
              in >> headChunk;
              headChunk = qFromBigEndian<qint32>(headChunk);

              in >> chunkSize;
              quint16 audioFormat;
              in >> audioFormat;
              audioFormat = qFromBigEndian<quint16>(audioFormat);
              qDebug() << "format" << reinterpret_cast<char*>(&headChunk) << audioFormat;
              if (headChunk == 544501094 && audioFormat == 1) { // 544501094 is 'value' of 'fmt ' text in valid WAV file
                  in >> channelsNr;
                  channelsNr = qFromBigEndian<quint16>(channelsNr);
                  in >> sampleRate;
                  sampleRate = qFromBigEndian<quint32>(sampleRate);
                  quint32 byteRate;
                  in >> byteRate;
                  byteRate = qFromBigEndian<quint32>(byteRate);
                  quint16 blockAlign;
                  in >> blockAlign;
                  blockAlign = qFromBigEndian<quint16>(blockAlign);
                  quint16 bitsPerSample;
                  in >> bitsPerSample;
                  bitsPerSample = qFromBigEndian<quint16>(bitsPerSample);
                  if (bitsPerSample != 16) {
                    qDebug() << "[TcountingImport] Only *.wav with 16 bit per sample are supported.";
                    ok = false;
                  }
                  in >> headChunk;
                  headChunk = qFromBigEndian<qint32>(headChunk);

                  quint32 audioDataSize;
                  in >> audioDataSize;
                  audioDataSize = qFromBigEndian<quint32>(audioDataSize);

                  frames = audioDataSize / (channelsNr * 2);
                  data = new qint16[audioDataSize / 2];
                  qint16 channelSample;
                  for (int f = 0; f < frames; ++f) {
                    in >> channelSample;
                    if (channelsNr == 2) // prefer right channel when stereo
                      in >> channelSample;
                    data[f] = qFromBigEndian<qint16>(channelSample);
                  }
                  frames = audioDataSize / 2;
              } else {
                  qDebug() << "[TcountingImport] Unsupported audio format in file:" << fileName;
                  ok = false;
              }
          } else {
              qDebug() << "[TcountingImport] "<< fileName << "is not valid *,wav file";
              ok = false;
          }
      } else if (ext == QLatin1String("raw")) {
          frames = static_cast<int>(audioF.size() / 2);
          data = new qint16[frames];
          QDataStream stream(&audioF);
          stream.readRawData(reinterpret_cast<char*>(data), frames * 2);
      }
  } else {
      ok = false;
      qDebug() << "[TcountingImport] Cannot open file" << fileName;
  }

  if (!ok)
    return;

// determine noise level
  qint16 noiseLevel = 10;
  for (int f = 0; f < 48000; ++f) {
    noiseLevel = qMax(noiseLevel, qAbs(data[f]));
  }
  qDebug() << "Noise level is" << noiseLevel;

// find numerals data and mark them: point.x = start, point.y = end
  qint16 max = 0;
  bool onSetFound = false;
  int onSetAt = 0;
  int onEndAt = 0;
  int silCnt = 0;
  QVector<QPoint> numerals;

  for (int f = 48001; f < frames; ++f) {
    qint16 absData = qAbs(data[f]);
    if (onSetFound) {
        if (max && ((data[f] >= 0 && data[f - 1] <= 0))) {
          if (max > noiseLevel) {
              silCnt = 0;
          } else {
              if (f - onSetAt > 9000) { // 187.5 ms at least
                silCnt++;
                if (silCnt > 30) {
                    onSetFound = false;
                    onEndAt = f;
                    silCnt = 0;
                    numerals << QPoint(onSetAt, onEndAt);
                    qDebug() << "finished" << onEndAt << (onEndAt / 48000.0) << "dur:" << (onEndAt - onSetAt) << ((onEndAt - onSetAt) / 48000.0);
                }
              } else if (f - onSetAt > 2000) { // 55 ms
                  silCnt++;
                  if (silCnt > 30) {
                    onSetFound = false;
                    silCnt = 0;
                  }
              }
          }
          max = 0;
        }
        max = qMax(max, absData);
    } else {
        if (absData > noiseThreshold) {
          onSetFound = true;
          int pos = f - 1;
          while ((data[pos] >= 0 && data[pos - 1] >= 0) || (data[pos] < 0 && data[pos - 1] < 0))
            pos--;
          onSetAt = pos;
          qDebug() << numerals.count() + 1 << "\non set at" << pos << (pos / 48000.0);
          max = 0;
        }
    }
  }

// copy numerals samples into TaudioOut
  if (!numerals.isEmpty()) {
    qDebug() << "Found" << numerals.size();

    bool doCreate = m_numerals->isEmpty();

    for (int d = 0; d < 12; ++d) {
      if (d < numerals.size()) {
        auto marks = numerals[d];
        if (doCreate)
          m_numerals->append(new TsoundData(data + marks.x(), marks.y() - marks.x()));
        else
          m_numerals->at(d)->copyData(data + marks.x(), marks.y() - marks.x());
      }
    }
//     if (!outDir.isEmpty()) {
//       for (int n =0; n < numerals.size(); ++n) {
//         QPoint& num = numerals[n];
//         QFile rawF(QString("%1/%2.raw48-16").arg(outDir).arg(n + 1, 2, 'g', -1, '0'));
//         if (rawF.open(QIODevice::ReadWrite)) {
//           rawF.write(reinterpret_cast<char*>(data + num.x()), (num.y() - num.x()) * 2);
//         }
//       }
//     }
  }

  delete[] data;
}


// void TcountingImport::setFinished(bool finished)
// {
//   if (m_finished != finished) {
//     m_finished = finished;
//     emit finishedChanged();
//   }
// }
