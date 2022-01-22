/** This file is part of Metronomek                                  *
 * Copyright (C) 2022 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#ifndef TCOUNTINGIMPORT_H
#define TCOUNTINGIMPORT_H


#include <QtCore/qobject.h>


class TsoundData;
class TabstractAudioDevice;


/**
 * 
 */
class TcountingImport : public QObject
{

  Q_OBJECT

public:
  TcountingImport(QVector<TsoundData*>* numList, QObject* parent = nullptr);

      /**
       * @p TRUE when import was done
       */
  bool finished() const { return m_finished; }
//   void setFinished(bool finished);

  void importFormFile(const QString& fileName, int noiseThreshold = 400);

  void importFromCommandline();

#if defined (Q_OS_ANDROID)
  void importFromTTS();
#endif

//   void importFromResources();

  void initSettings(TabstractAudioDevice* audioDev);
  void restoreSettings();

  Q_INVOKABLE void play(int numer);

signals:
  void finishedChanged();

protected:
#if defined (WITH_SOUNDTOUCH)
      /**
       * Changes length of @p in counting data to appropriate duration: 300ms.
       * Saves new stream into @p out with duration @p outLen frames
       */
  void squash(qint16* in, quint32 inLen, qint16*& out, quint32& outLen);
#endif

  void playCallBack(char* data, unsigned int maxLen, unsigned int& wasRead);

private:
  bool                              m_finished = false;
  QVector<TsoundData*>             *m_numerals = nullptr;
  bool                              m_doSquash = false;
  bool                              m_alignCounting = true;
  TabstractAudioDevice             *m_audioDevice = nullptr;
  int                               m_currSample = 0;
  int                               m_playNum = 0;
};

#endif // TCOUNTINGIMPORT_H
