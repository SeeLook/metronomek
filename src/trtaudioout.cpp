/** This file is part of Metronomek                                  *
 * Copyright (C) 2021 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#include "trtaudioout.h"

#include <QtCore/qfileinfo.h>
#include <QtCore/qdebug.h>


/*static*/

#define                            PREF_BUFF_FR (512) /**< Preferred frame size of audio buffer */

RtAudio*                           TrtAudioOut::m_rtAduio = nullptr;
TrtAudioOut*                       TrtAudioOut::m_instance = nullptr;


void TrtAudioOut::createRtAudio() {
  if (m_rtAduio == nullptr) { // Create RtAudio instance only if doesn't exist
    RtAudio::Api rtAPI = RtAudio::RTAUDIO_DUMMY;
  #if defined(Q_OS_WIN)
      rtAPI = RtAudio::WINDOWS_WASAPI;
  #elif defined(Q_OS_LINUX)
    #if defined(__LINUX_ALSA__)
      rtAPI = RtAudio::LINUX_ALSA;
    #endif
    #if defined(__LINUX_PULSE__)
      QFileInfo pulseBin(QStringLiteral("/usr/bin/pactl"));
      if (!pulseBin.exists())
        pulseBin.setFile(QStringLiteral("/usr/bin/pipewire-pulse"));
      if (pulseBin.exists()) // we check is PA possible to run - without check, it can hang.
        rtAPI = RtAudio::LINUX_PULSE;
    #endif
  #else
      rtAPI = RtAudio::MACOSX_CORE;
  #endif

    try {
        m_rtAduio = new RtAudio(rtAPI);
        m_rtAduio->showWarnings(false);
    } catch (RtAudioError& e) {
        qDebug() << "[TrtAudioOut] Cannot create RtAudio instance" << QString::fromStdString(e.getMessage());
        m_rtAduio = nullptr;
    }
  }
}


RtAudio::Api TrtAudioOut::getCurrentApi() {
  RtAudio::Api api = RtAudio::UNSPECIFIED;
  if (rtDevice()) {
    try {
        api = rtDevice()->getCurrentApi();
    } catch (RtAudioError& e) {
        qDebug() << "[TrtAudioOut] Cannot determine current API";;
    }
  }
  return api;
}


bool TrtAudioOut::getDeviceInfo(RtAudio::DeviceInfo& devInfo, unsigned int id) {
  try {
      devInfo = rtDevice()->getDeviceInfo(id);
  }
  catch (RtAudioError& e) {
      qDebug() << "[TrtAudioOut] error when probing audio device" << id;
      return false;
  }
  return true;
}


unsigned int TrtAudioOut::getDeviceCount() {
  unsigned int cnt = 0;
  if (rtDevice()) {
    try {
        cnt = rtDevice()->getDeviceCount();
    } catch (RtAudioError& e) {
        qDebug() << "[TrtAudioOut] Cannot obtain devices number";
    }
  }
  return cnt;
}


int TrtAudioOut::getDefaultOutput() {
  int outNr = -1;
  if (rtDevice()) {
    try {
        outNr = rtDevice()->getDefaultOutputDevice();
    } catch (RtAudioError& e) {
        qDebug() << "[TrtAudioOut] Cannot get default output device";
    }
  }
  return outNr;
}


int TrtAudioOut::rtCallBack(void* outBuffer, void*, unsigned int nBufferFrames, double, RtAudioStreamStatus status, void*) {
  Q_UNUSED(status)
  unsigned int retVal = 0;
  m_instance->emitFeedAudio(static_cast<char*>(outBuffer), nBufferFrames, retVal);
  return static_cast<int>(retVal);
}



TrtAudioOut::TrtAudioOut(QObject* parent) :
  TabstractAudioDevice(parent)
{
  m_instance = this;

  m_streamOptions = new RtAudio::StreamOptions;
  m_streamOptions->streamName = "Metronomek"; // NOTE - It makes sense only with JACK
  m_outParams = new RtAudio::StreamParameters;

  m_instance->createRtAudio();
}


TrtAudioOut::~TrtAudioOut()
{
  m_instance = nullptr;
  delete m_streamOptions;
  delete m_outParams;
}


QStringList TrtAudioOut::getAudioDevicesList() {
  QStringList devList;
  createRtAudio();
  if (m_instance && getCurrentApi() == RtAudio::LINUX_ALSA)
    m_instance->closeStream(); // close ALSA stream to get full list of devices
  int devCnt = getDeviceCount();
  if (devCnt < 1)
    return devList;

  for (int i = 0; i < devCnt; i++) {
    RtAudio::DeviceInfo devInfo;
    if (!getDeviceInfo(devInfo, i))
      continue;
    if (devInfo.probed && devInfo.outputChannels > 0)
      devList << convDevName(devInfo);
  }
  if (getCurrentApi() == RtAudio::LINUX_ALSA && !devList.isEmpty())
    devList.prepend(QStringLiteral("ALSA default"));

  return devList;
}


void TrtAudioOut::setAudioOutParams() {
  closeStream();

  // preparing devices
  int outDevId = -1;
  unsigned int devCount = getDeviceCount();
  m_isAlsaDefault = false;
  m_streamOptions->flags = !RTAUDIO_ALSA_USE_DEFAULT; // reset options flags
  if (devCount) {
      RtAudio::DeviceInfo devInfo;
      for(unsigned int i = 0; i < devCount; i++) { // Is there device on the list ??
        if (getDeviceInfo(devInfo, i)) {
          if (devInfo.probed) {
            if (m_outParams && devInfo.outputChannels > 0 && convDevName(devInfo) == m_outDevName) {
              outDevId = static_cast<int>(i);
              m_outDevName = convDevName(devInfo);
            }
          }
        }
      }

      if (outDevId == -1) {
        if (getCurrentApi() != RtAudio::LINUX_ALSA) {
          outDevId = getDefaultOutput();
          RtAudio::DeviceInfo outInfo;
          getDeviceInfo(outInfo, static_cast<unsigned int>(outDevId));
          if (outDevId > -1) {
            if (outInfo.outputChannels <= 0) {
              qDebug() << "[TrtAudioOut] wrong default output device";
              delete m_outParams;
              m_outParams = nullptr;
            }
          }
        }
      }
      // Default ALSA device can be set only when both devices are undeclared
      if (outDevId == -1 && getCurrentApi() == RtAudio::LINUX_ALSA) {
        m_streamOptions->flags = RTAUDIO_ALSA_USE_DEFAULT;
        m_isAlsaDefault = true;
        if (m_outParams)
          outDevId = 0;
      }
  } else {
      qDebug() << "[TrtAudioOut] No audio devices!";
      return;
  }

  // setting device parameters
  if (m_outParams) {
    m_outParams->deviceId = static_cast<unsigned int>(outDevId);
    m_outParams->nChannels = 2;
    m_outParams->firstChannel = 0;
  }
  RtAudio::DeviceInfo outDevInfo;
  if (m_outParams && !getDeviceInfo(outDevInfo, static_cast<unsigned int>(outDevId))) {
    delete m_outParams;
    m_outParams = nullptr;
  }

  setSamplaRate(determineSampleRate(outDevInfo));

#if !defined (Q_OS_MAC) // Mac has reaction for this flag - it opens streams with 15 buffer frames
  m_streamOptions->flags |= RTAUDIO_MINIMIZE_LATENCY;
#endif
  openStream();
}


void TrtAudioOut::setDeviceName(const QString& devName) {
  if (devName != m_outDevName) {
    m_outDevName = devName;
    setAudioOutParams();
  }
}


void TrtAudioOut::startPlaying() {
  if (rtDevice()) {
    startStream();
    p_isPlaying = true;
  }
}


void TrtAudioOut::stopPlaying() {
  if (p_isPlaying) {
    if (getCurrentApi() == RtAudio::LINUX_PULSE) {
        abortStream();
        closeStream();
    } else
        stopStream();
    p_isPlaying = false;
  }
}


//#################################################################################################
//###################                PROTECTED         ############################################
//#################################################################################################

bool m_devNameDbgMessage = true;
bool TrtAudioOut::openStream() {
  try {
    if (rtDevice()) {
      unsigned int m_bufferFrames = PREF_BUFF_FR; // reset when it was overridden by another rt API
      if (!rtDevice()->isStreamOpen())
        rtDevice()->openStream(m_outParams, nullptr, RTAUDIO_SINT16, sampleRate(), &m_bufferFrames, rtCallBack, nullptr, m_streamOptions);

      if (rtDevice()->isStreamOpen()) {
          if (m_isAlsaDefault) {
              if (m_outParams)
                m_outDevName = QLatin1String("ALSA default");
          } else {
              RtAudio::DeviceInfo di;
              if (m_outParams && getDeviceInfo(di, m_outParams->deviceId))
                m_outDevName = convDevName(di);
          }
          if (m_devNameDbgMessage) { // print params once
            if (m_outParams)
              qDebug() << RtAudio::getApiName(getCurrentApi()).data() << "OUT:" << m_outDevName
                       << ", sample rate:" << sampleRate() << ", buffer size:" << m_bufferFrames;
            m_devNameDbgMessage = false;
          }
          return true;
      } else
          return false;
    }
  } catch (RtAudioError& e) {
      qDebug() << "[TrtAudioOut] can't open stream" << m_outDevName << "\n" << QString::fromStdString(e.getMessage());
      return false;
  }
  return true;
}


bool TrtAudioOut::isOpened() {
  if (rtDevice()) {
    try {
        return rtDevice()->isStreamOpen();
    } catch (RtAudioError& e) {
        return false;
    }
  }
  return false;
}


bool TrtAudioOut::startStream() {
  if (!isOpened()) {
    if (!openStream())
      return false;
  }
  try {
      if (rtDevice() && !rtDevice()->isStreamRunning()) {
        rtDevice()->startStream();
    }
  } catch (RtAudioError& e) {
      qDebug() << "[TrtAudioOut] can't start stream";
      return false;
  }
  //   qDebug("[TrtAudioOut] stream started");
  return true;
}


void TrtAudioOut::stopStream() {
  try {
      if (rtDevice() && rtDevice()->isStreamRunning()) {
        rtDevice()->stopStream();
        //       qDebug("[TrtAudioOut] stream stopped");
      }
  } catch (RtAudioError& e) {
      qDebug() << "[TrtAudioOut] can't stop stream";
  }
}


void TrtAudioOut::closeStream() {
  try {
      stopStream();
      if (rtDevice() && rtDevice()->isStreamOpen()) {
      rtDevice()->closeStream();
      //       qDebug("[TrtAudioOut] stream closed");
    }
  } catch (RtAudioError& e) {
      qDebug() << "[TrtAudioOut] can't close stream";
  }
}


void TrtAudioOut::abortStream() {
  try {
      if (rtDevice() && rtDevice()->isStreamRunning()) {
        rtDevice()->abortStream();
        //       qDebug("[TrtAudioOut] stream aborted");
      }
  }catch (RtAudioError& e) {
      qDebug() << "[TrtAudioOut] can't abort stream";
  }
}


quint32 TrtAudioOut::determineSampleRate(RtAudio::DeviceInfo& devInfo) {
//   return devInfo.preferredSampleRate;
  static const quint32 srArr[4] = { 48000, 44100, 96000, 192000 };
  for (int s = 0; s < 4; ++s) {
    for (int i = 0; i < devInfo.sampleRates.size(); i++) {
      quint32 sr = devInfo.sampleRates.at(i);
      if (srArr[s] == sr)
        return sr;
    }
  }

  if (devInfo.sampleRates.size() > 0)
    return devInfo.sampleRates.at(devInfo.sampleRates.size() - 1);
  else
    return 48000;
}
