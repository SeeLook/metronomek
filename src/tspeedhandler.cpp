/** This file is part of Metronomek                                  *
 * Copyright (C) 2021 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#include "tspeedhandler.h"
#include "ttempopart.h"
#include "taudioout.h"

// #include <QtCore/qtimer.h>
#include <QtCore/qdebug.h>


TspeedHandler::TspeedHandler(QObject* parent) :
  QObject(parent)
{

  m_tempoList << createTempoPart();
}


TspeedHandler::~TspeedHandler()
{
}


void TspeedHandler::add() {
  int t = m_tempoList.isEmpty() ? SOUND->tempo() : m_tempoList.last()->targetTempo();
  m_tempoList << createTempoPart(t);
  emit appendTempoChange(m_tempoList.last());
}


void TspeedHandler::emitAllTempos() {
  for (auto tp : m_tempoList)
    emit appendTempoChange(tp);
}


int TspeedHandler::getTempoForBeat(int partId, int beatNr) {
  if (partId < m_tempoList.count())
    return m_tempoList[partId]->getTempoForBeat(beatNr);
  else
    return 0;

//   return SOUND->tempo();
}

//#################################################################################################
//###################                PROTECTED         ############################################
//#################################################################################################

TtempoPart * TspeedHandler::createTempoPart(int tempo) {
  auto tp = new TtempoPart(m_tempoList.size() + 1, this);
  int t = tempo < 40 || tempo > 240 ? SOUND->tempo() : tempo;
  tp->setTempos(t, t);
  return tp;
}
