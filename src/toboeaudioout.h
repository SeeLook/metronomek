/** This file is part of Metronomek                                  *
 * Copyright (C) 2021 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#ifndef TOBOEAUDIOOUT_H
#define TOBOEAUDIOOUT_H


#include "tabstractaudiooutput.h"
#include <oboe/Oboe.h>


class ToboeCallBack;


/**
 * @todo write docs
 */
class ToboeAudioOut : public TabstractAudioDevice
{

  Q_OBJECT

public:
  ToboeAudioOut(QObject* parent = nullptr);
  ~ToboeAudioOut();

  void startPlaying() override;
  void stopPlaying() override;

  void setDeviceName(const QString& devName) override;
  QString deviceName() const override;

  void setAudioOutParams() override;

private:
  oboe::AudioStreamBuilder             *m_oboe = nullptr;
  std::shared_ptr<oboe::AudioStream>    m_stream;
  ToboeCallBack                        *m_callBackClass = nullptr;

};

#endif // TOBOEAUDIOOUT_H
