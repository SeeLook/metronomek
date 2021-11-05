##############################################################################
# This file is part of Metronomek                                            #
# Copyright (C) 2021 by Tomasz Bojczuk (seelook@gmail.com)                   #
# on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)            #
##############################################################################

if (UNIX)

  if (APPLE)
      find_library(CoreAudio_LIB             NAMES CoreAudio)
      find_library(CoreMidi_LIB              NAMES CoreMIDI)
      find_library(CoreFoundation_LIB        NAMES CoreFoundation)
      add_definitions(-D__MACOSX_CORE__)

  else()
      # Linux ALSA and/or PulseAudio
      find_package(ALSA)
      if (ALSA_FOUND)
          add_definitions(-D__LINUX_ALSA__)
          include_directories(${ALSA_INCLUDE_DIRS})
          message(STATUS "support for ALSA\t\t TRUE")
          set(ALSA_LIBRARIES ${ALSA_LIBRARIES} PARENT_SCOPE)
      else()
          message(STATUS "support for ALSA\t\t FALSE")
      endif()

      find_package(PulseAudio)
      if (PulseAudio_FOUND)
          add_definitions(-D__LINUX_PULSE__)
          message(STATUS "support for PulseAudio\t TRUE")
          find_path(PulseAudio_INCLUDE_DIRS
            NAMES
              pulseaudio.h
            PATHS
              /usr/include
              /usr/include/pulse
              /usr/local/include
              /opt/local/include
          )
          include_directories(${PulseAudio_INCLUDE_DIRS})
          find_library(PulseAudio_LIBRARIES
              NAMES
              pulse pulse-simple
              PATHS
              /lib
              /usr/lib
              /usr/lib/x86_64-linux-gnu
              /usr/local/lib
              /opt/local/lib
          )
          find_library(PulseAudio_Simple_LIBRARIES
              NAMES
              pulse-simple
              PATHS
              /lib
              /usr/lib
              /usr/lib/x86_64-linux-gnu
              /usr/local/lib
              /opt/local/lib
          )

      else()
          message(STATUS "support for PulseAudio\t FALSE")
      endif()

      if (ALSA_FOUND OR PulseAudio_FOUND)
          find_library(PTHREAD_LIBRARIES
            NAMES
            pthread
            PATHS
            /usr/lib
            /usr/lib/x86_64-linux-gnu
            /usr/local/lib
            /opt/local/lib
            REQUIRED
          )
          set(RtAudio_LIBRARIES
              ${ALSA_LIBRARIES} ${PulseAudio_LIBRARIES} ${PulseAudio_Simple_LIBRARIES}
              ${PTHREAD_LIBRARIES}
              PARENT_SCOPE
          )
      else()
          message(STATUS "No audio libraries found!")
      endif()

  endif()

elseif (WIN32)
  set(RtAudio_LIBRARIES winmm ole32 mfuuid ksuser mfplat wmcodecdspuuid PARENT_SCOPE)
  add_definitions(-D__WINDOWS_WASAPI__)

endif()
