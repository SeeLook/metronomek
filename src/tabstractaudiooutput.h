/** This file is part of Metronomek                                  *
 * Copyright (C) 2021 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#ifndef TABSTRACTAUDIOOUTPUT_H
#define TABSTRACTAUDIOOUTPUT_H


#include <QtCore/qobject.h>


/**
 * 
 */
class TabstractAudioOutput : public QObject
{

  Q_OBJECT

public:
  TabstractAudioOutput(QObject* parent = nullptr);

  virtual void setAudioOutParams() = 0;

      /**
       * Output device name - will be stored in config
       */
  virtual QString deviceName() const = 0;

      /**
       * Sets desired (used before) output device by its name.
       * Should invoke audio settings to approve device change
       */
  virtual void setDeviceName(const QString& devName) = 0;

  virtual void startPlaying() = 0;
  virtual void stopPlaying() = 0;

  bool isPlaying() const { return p_isPlaying; }

signals:
  void feedAudio(char*, unsigned int, unsigned int&);
  void stateChenged();

protected:
  bool                  p_isPlaying = false;

};

#endif // TABSTRACTAUDIOOUTPUT_H
