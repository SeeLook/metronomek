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
          set(ALSA_LINK ${ALSA_LIBRARIES} PARENT_SCOPE)
      else()
          message(STATUS "support for ALSA\t\t FALSE")
      endif()

      find_package(PulseAudio)
      if (PulseAudio_FOUND)
          add_definitions(-D__LINUX_PULSE__)
          include_directories(${PulseAudio_INCLUDE_DIRS})
          message(STATUS "support for PulseAudio\t TRUE")
          set(PulseAudio_LINK ${PulseAudio_LIBRARIES} PARENT_SCOPE)
      else()
          message(STATUS "support for PulseAudio\t FALSE")
      endif()

      if (ALSA_FOUND OR PulseAudio_FOUND)
          target_sources(metronomek PRIVATE RtAudio.cpp)
      else()
          message(STATUS "No audio libraries found!")
      endif()

  endif()

endif()
