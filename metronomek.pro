# This file is part of Metronomek
# Copyright (C) 2019-2022 by Tomasz Bojczuk (seelook@gmail.com)
# on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)

android: TARGET = MetronomeK
else: {
  TARGET = metronomek
  error("To configure and build MetronomeK for desktop PC (Linux, Mac Windows) use cmake! This qmake script is for Android only!")
}

TEMPLATE = app

VERSION = $$system(sed -n \"9 p\" $$PWD/CMakeLists.txt | awk -F\" \" \'{ print $2 }\' | sed \'s/\"//g\' | sed \'s/\)//g\')

ANDROID_VERSION_NAME = $$VERSION
ANDROID_VERSION_CODE = "4"

QMAKE_SUBSTITUTES += src/metronomek_conf.h.in

QT += gui quick quickcontrols2 androidextras #multimedia

CONFIG += c++17 # c++11 is fine Metronomek itself but Oboe wants c++17

# Actually it has to be 5.14 for Android due to newer manifest quirks
!versionAtLeast(QT_VERSION, 5.14.0) {
    message("Cannot use Qt $${QT_VERSION}")
    error("Use Qt 5.14 or newer")
}

DEFINES += QT_DEPRECATED_WARNINGS
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        src/main.cpp \
        src/tglob.cpp \
        src/tsound.cpp \
        src/tabstractaudiodevice.cpp \
#        src/tqtaudioout.cpp \
        src/toboeaudioout.cpp \
        src/tsounddata.cpp \
        src/tnumeralspectrum.cpp \
        src/tcountingimport.cpp \
        src/tmetroshape.cpp \
        \
        src/tspeedhandler.cpp \
        src/ttempopart.cpp \
        \
        src/android/tandroid.cpp \

HEADERS += \
        src/tglob.h \
        src/taudiobuffer.h \
        src/tsound.h \
        src/tabstractaudiodevice.h \
#        src/tqtaudioout.h \
        src/toboeaudioout.h \
        src/tsounddata.h \
        src/tnumeralspectrum.h \
        src/tcountingimport.h \
        src/tmetroshape.h \
        \
        src/tspeedhandler.h \
        src/ttempopart.h \
        \
        src/android/tandroid.h\

RESOURCES += src/qml/metronomek_qml.qrc images/metronomek_images.qrc

sounds.path = /assets/sounds
translations.path = /assets/translations

sounds.files = sounds/*
sounds.depends += FORCE

translations.files = $$files(translations/*.qm, true)
translations.depends += FORCE

license.files = LICENSE

INSTALLS += sounds translations

DISTFILES += \
  installs/android/AndroidManifest.xml \
  installs/android/build.gradle \
  installs/android/gradle/wrapper/gradle-wrapper.jar \
  installs/android/gradle/wrapper/gradle-wrapper.properties \
  installs/android/gradlew \
  installs/android/gradlew.bat \
  installs/android/res/values/libs.xml

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/installs/android


# Google Oboe audio library

LIBS += -lOpenSLES

OBOE_SOURCES = src/oboe/src/aaudio/AAudioLoader.cpp \
    src/oboe/src/aaudio/AudioStreamAAudio.cpp \
    src/oboe/src/common/AudioSourceCaller.cpp \
    src/oboe/src/common/AudioStream.cpp \
    src/oboe/src/common/AudioStreamBuilder.cpp \
    src/oboe/src/common/DataConversionFlowGraph.cpp \
    src/oboe/src/common/FilterAudioStream.cpp \
    src/oboe/src/common/FixedBlockAdapter.cpp \
    src/oboe/src/common/FixedBlockReader.cpp \
    src/oboe/src/common/FixedBlockWriter.cpp \
    src/oboe/src/common/LatencyTuner.cpp \
    src/oboe/src/common/SourceFloatCaller.cpp \
    src/oboe/src/common/SourceI16Caller.cpp \
    src/oboe/src/common/SourceI24Caller.cpp \
    src/oboe/src/common/SourceI32Caller.cpp \
    src/oboe/src/common/Utilities.cpp \
    src/oboe/src/common/QuirksManager.cpp \
    src/oboe/src/fifo/FifoBuffer.cpp \
    src/oboe/src/fifo/FifoController.cpp \
    src/oboe/src/fifo/FifoControllerBase.cpp \
    src/oboe/src/fifo/FifoControllerIndirect.cpp \
    src/oboe/src/flowgraph/FlowGraphNode.cpp \
    src/oboe/src/flowgraph/ChannelCountConverter.cpp \
    src/oboe/src/flowgraph/ClipToRange.cpp \
    src/oboe/src/flowgraph/ManyToMultiConverter.cpp \
    src/oboe/src/flowgraph/MonoToMultiConverter.cpp \
    src/oboe/src/flowgraph/MultiToMonoConverter.cpp \
    src/oboe/src/flowgraph/RampLinear.cpp \
    src/oboe/src/flowgraph/SampleRateConverter.cpp \
    src/oboe/src/flowgraph/SinkFloat.cpp \
    src/oboe/src/flowgraph/SinkI16.cpp \
    src/oboe/src/flowgraph/SinkI24.cpp \
    src/oboe/src/flowgraph/SinkI32.cpp \
    src/oboe/src/flowgraph/SourceFloat.cpp \
    src/oboe/src/flowgraph/SourceI16.cpp \
    src/oboe/src/flowgraph/SourceI24.cpp \
    src/oboe/src/flowgraph/SourceI32.cpp \
    src/oboe/src/flowgraph/resampler/IntegerRatio.cpp \
    src/oboe/src/flowgraph/resampler/LinearResampler.cpp \
    src/oboe/src/flowgraph/resampler/MultiChannelResampler.cpp \
    src/oboe/src/flowgraph/resampler/PolyphaseResampler.cpp \
    src/oboe/src/flowgraph/resampler/PolyphaseResamplerMono.cpp \
    src/oboe/src/flowgraph/resampler/PolyphaseResamplerStereo.cpp \
    src/oboe/src/flowgraph/resampler/SincResampler.cpp \
    src/oboe/src/flowgraph/resampler/SincResamplerStereo.cpp \
    src/oboe/src/opensles/AudioInputStreamOpenSLES.cpp \
    src/oboe/src/opensles/AudioOutputStreamOpenSLES.cpp \
    src/oboe/src/opensles/AudioStreamBuffered.cpp \
    src/oboe/src/opensles/AudioStreamOpenSLES.cpp \
    src/oboe/src/opensles/EngineOpenSLES.cpp \
    src/oboe/src/opensles/OpenSLESUtilities.cpp \
    src/oboe/src/opensles/OutputMixerOpenSLES.cpp \
    src/oboe/src/common/StabilizedCallback.cpp \
    src/oboe/src/common/Trace.cpp \
    src/oboe/src/common/Version.cpp \

OBOE_HEADERS = src/oboe/src/aaudio/AAudioLoader.h \
    src/oboe/src/aaudio/AudioStreamAAudio.h \
    src/oboe/src/common/AudioSourceCaller.h \
    src/oboe/src/common/DataConversionFlowGraph.h \
    src/oboe/src/common/FilterAudioStream.h \
    src/oboe/src/common/FixedBlockAdapter.h \
    src/oboe/src/common/FixedBlockReader.h \
    src/oboe/src/common/FixedBlockWriter.h \
    src/oboe/src/common/SourceFloatCaller.h \
    src/oboe/src/common/SourceI16Caller.h \
    src/oboe/src/common/SourceI24Caller.h \
    src/oboe/src/common/SourceI32Caller.h \
    src/oboe/src/common/QuirksManager.h \
    src/oboe/src/fifo/FifoBuffer.h \
    src/oboe/src/fifo/FifoController.h \
    src/oboe/src/fifo/FifoControllerBase.h \
    src/oboe/src/fifo/FifoControllerIndirect.h \
    src/oboe/src/flowgraph/FlowGraphNode.h \
    src/oboe/src/flowgraph/ChannelCountConverter.h \
    src/oboe/src/flowgraph/ClipToRange.h \
    src/oboe/src/flowgraph/ManyToMultiConverter.h \
    src/oboe/src/flowgraph/MonoToMultiConverter.h \
    src/oboe/src/flowgraph/MultiToMonoConverter.h \
    src/oboe/src/flowgraph/RampLinear.h \
    src/oboe/src/flowgraph/SampleRateConverter.h \
    src/oboe/src/flowgraph/SinkFloat.h \
    src/oboe/src/flowgraph/SinkI16.h \
    src/oboe/src/flowgraph/SinkI24.h \
    src/oboe/src/flowgraph/SinkI32.h \
    src/oboe/src/flowgraph/SourceFloat.h \
    src/oboe/src/flowgraph/SourceI16.h \
    src/oboe/src/flowgraph/SourceI24.h \
    src/oboe/src/flowgraph/SourceI32.h \
    src/oboe/src/flowgraph/resampler/IntegerRatio.h \
    src/oboe/src/flowgraph/resampler/LinearResampler.h \
    src/oboe/src/flowgraph/resampler/MultiChannelResampler.h \
    src/oboe/src/flowgraph/resampler/PolyphaseResampler.h \
    src/oboe/src/flowgraph/resampler/PolyphaseResamplerMono.h \
    src/oboe/src/flowgraph/resampler/PolyphaseResamplerStereo.h \
    src/oboe/src/flowgraph/resampler/SincResampler.h \
    src/oboe/src/flowgraph/resampler/SincResamplerStereo.h \
    src/oboe/src/opensles/AudioInputStreamOpenSLES.h \
    src/oboe/src/opensles/AudioOutputStreamOpenSLES.h \
    src/oboe/src/opensles/AudioStreamBuffered.h \
    src/oboe/src/opensles/AudioStreamOpenSLES.h \
    src/oboe/src/opensles/EngineOpenSLES.h \
    src/oboe/src/opensles/OpenSLESUtilities.h \
    src/oboe/src/opensles/OutputMixerOpenSLES.h \
    src/oboe/src/common/Trace.h \

INCLUDEPATH_OBOE = src/oboe/include/ \
    src/oboe/src/

DISTFILES_OBOE += src/oboe/AUTHORS \
    src/oboe/CONTRIBUTING \
    src/oboe/LICENSE \
    src/oboe/README

INCLUDEPATH += $$INCLUDEPATH_OBOE
HEADERS += $$OBOE_HEADERS
SOURCES += $$OBOE_SOURCES
DISTFILES += $$DISTFILES_OBOE
