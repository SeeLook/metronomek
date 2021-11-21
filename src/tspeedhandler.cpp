/** This file is part of Metronomek                                  *
 * Copyright (C) 2021 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#include "tspeedhandler.h"
#include "ttempopart.h"
#include "taudioout.h"
#include "tglob.h"

#include <QtCore/qxmlstream.h>
#include <QtCore/qfile.h>
#include <QtCore/qdir.h>
#include <QtCore/qfileinfo.h>
#include <QtCore/qsettings.h>

#include <QtCore/qdebug.h>


TspeedHandler::TspeedHandler(QObject* parent) :
  QObject(parent)
{

  readFromXMLFile(QDir::toNativeSeparators(QFileInfo(
    GLOB->settings()->fileName()).absolutePath() + QLatin1String("/tempoChanges.metronomek.xml")
  ));
//   m_tempoList << createTempoPart();
}


TspeedHandler::~TspeedHandler()
{
  saveToXMLFile(QDir::toNativeSeparators(QFileInfo(
    GLOB->settings()->fileName()).absolutePath() + QLatin1String("/tempoChanges.metronomek.xml")
  ));
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
}


void TspeedHandler::saveToXMLFile(const QString& xmlFile) {
  if (xmlFile.isEmpty())
    return;

  QFile file(xmlFile);
  if (file.open(QIODevice::WriteOnly)) {
      QXmlStreamWriter xml(&file);
      xml.setAutoFormatting(true);
      xml.setAutoFormattingIndent(2);
      xml.writeStartDocument();
      xml.writeComment("\nXML file of Metronomek tempo changes.\nhttps://metronomek.sourceforge.io\nDo not edit this file manually!\n");
        xml.writeStartElement(QLatin1String("metronomek"));
          for (auto p : m_tempoList)
            p->writeToXML(xml);
        xml.writeEndElement();
      xml.writeEndDocument();
      file.close();
  } else {
      qDebug() << "[TspeedHandler] Cannot write to" << xmlFile;
  }
}


void TspeedHandler::readFromXMLFile(const QString& xmlFile) {
  if (xmlFile.isEmpty())
    return;

  QFile file(xmlFile);
  if (file.open(QIODevice::ReadOnly)) {
      QXmlStreamReader xml(&file);
      if (xml.readNextStartElement()) {
        if (xml.name() != QLatin1String("metronomek")) {
          qDebug() << "[TspeedHandler] There is no 'metronomek' key in that XML";
          return;
        }
        m_tempoList.clear();
        while (xml.readNextStartElement()) {
          if (xml.name() == QLatin1String("tempoChange")) {
              auto tp = new TtempoPart(m_tempoList.size() + 1, this);
              tp->readFromXML(xml);
              m_tempoList << tp;
          } else
              xml.skipCurrentElement();
        }
      }
  }
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
