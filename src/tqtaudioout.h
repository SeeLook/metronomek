/** This file is part of Metronomek                                  *
 * Copyright (C) 2021 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#ifndef TQTAUDIOOUT_H
#define TQTAUDIOOUT_H

#include "tabstractaudiodevice.h"
#include <QtMultimedia/qaudio.h>
#include <QtMultimedia/qaudiodeviceinfo.h>


class TaudioBuffer;
class QAudioOutput;


/**
 * @class TqtAudioOut is Android back-end of Metronomek audio
 */
class TqtAudioOut : public TabstractAudioDevice
{

  Q_OBJECT

public:
  TqtAudioOut(QObject* parent = nullptr);
  ~TqtAudioOut();

  static QStringList getAudioDevicesList();

  void stopPlaying() override;

  void startPlaying() override;

  void setDeviceName(const QString& devName) override;

  QString deviceName() const override;

  void setAudioOutParams() override;

protected:
  void createOutputDevice();

  void qtCallBack(char* data, qint64 maxLen, qint64& wasRead);

private:
  static TqtAudioOut           *m_instance;
  static QString                m_devName;
  QAudioOutput                 *m_audioOUT = nullptr;
  TaudioBuffer                 *m_buffer;
  QAudioDeviceInfo              m_deviceInfo;
  int                           m_bufferFrames, m_sampleRate;

};

#endif // TQTAUDIOOUT_H
