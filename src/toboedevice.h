/** This file is part of Metronomek                                  *
 * Copyright (C) 2021 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#ifndef TOBOEDEVICE_H
#define TOBOEDEVICE_H


#include "tabstractaudiodevice.h"
#include <oboe/Oboe.h>


class ToboeCallBack;


/**
 * @todo write docs
 */
class TOboeDevice : public TabstractAudioDevice
{

  Q_OBJECT

public:
  TOboeDevice(QObject* parent = nullptr);
  ~TOboeDevice();

  void startPlaying() override;
  void stopPlaying() override;

  void setDeviceName(const QString& devName) override;
  QString deviceName() const override;

  void setAudioOutParams() override;

private:
  oboe::AudioStreamBuilder               *m_oboe = nullptr;
  std::shared_ptr<oboe::AudioStream>      m_stream;
  ToboeCallBack                          *m_callBackClass = nullptr;

};

#endif // TOBOEDEVICE_H
