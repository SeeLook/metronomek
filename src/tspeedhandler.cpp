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
#include <QtCore/qtimer.h>
#include <QtCore/qstandardpaths.h>

#include <QtCore/qdebug.h>


//#################################################################################################
//###################          TrtmComposition         ############################################
//#################################################################################################

TrtmComposition::TrtmComposition(QObject* parent) :
  QObject(parent)
{
}


TrtmComposition::~TrtmComposition()
{
}


void TrtmComposition::setTitle(const QString& t) {
  if (t != m_title) {
    m_title = t;
    m_notSaved = true;
    emit titleChanged();
  }
}


void TrtmComposition::saveToXMLFile(const QString& xmlName) {
  if (!m_notSaved) {
    qDebug() << "[TrtmComposition] Nothing changed, nothing to save" << m_title;
    return;
  }

  if (xmlName.isEmpty() && m_xmlFileName.isEmpty())
    return;

  if (!xmlName.isEmpty())
    m_xmlFileName = xmlName;

  QFile file(m_xmlFileName);
  if (file.open(QIODevice::WriteOnly)) {
      QXmlStreamWriter xml(&file);
      xml.setAutoFormatting(true);
      xml.setAutoFormattingIndent(2);
      xml.writeStartDocument();
      xml.writeComment("\nXML file of Metronomek tempo changes.\nhttps://metronomek.sourceforge.io\nDo not edit this file manually!\n");
      xml.writeStartElement(QLatin1String("metronomek"));
      if (!m_title.isEmpty())
        xml.writeTextElement(QLatin1String("title"), m_title);
      for (auto p : m_tempoList)
        p->writeToXML(xml);
      xml.writeEndElement();
      xml.writeEndDocument();
      file.close();
      m_notSaved = false;
  } else {
      qDebug() << "[TrtmComposition] Cannot write to" << m_xmlFileName;
  }
}


void TrtmComposition::readFromXMLFile(const QString& xmlName) {
  if (xmlName.isEmpty())
    return;

  QFile file(xmlName);
  if (file.open(QIODevice::ReadOnly)) {
      setXmlFileName(xmlName);
      QXmlStreamReader xml(&file);
      if (xml.readNextStartElement()) {
        if (xml.name() != QLatin1String("metronomek")) {
          qDebug() << "[TspeedHandler] There is no 'metronomek' key in that XML" << xmlName;
          return;
        }
        m_tempoList.clear();
        while (xml.readNextStartElement()) {
          if (xml.name() == QLatin1String("title")) {
              setTitle(xml.readElementText());
          } else if (xml.name() == QLatin1String("tempoChange")) {
              auto tp = new TtempoPart(m_tempoList.size() + 1, this);
              tp->readFromXML(xml);
              m_tempoList << tp;
              connect(tp, &TtempoPart::infiniteChanged, this, &TrtmComposition::notSavedSlot);
              connect(tp, &TtempoPart::updateDuration, this, &TrtmComposition::notSavedSlot);
          } else
              xml.skipCurrentElement();
        }
      }
      m_notSaved = false;
  } else {
      qDebug() << "[TspeedHandler] Cannot read XML file:" << xmlName;
  }
}


void TrtmComposition::add() {
  int t = m_tempoList.isEmpty() ? SOUND->tempo() : m_tempoList.last()->targetTempo();
  m_tempoList << createTempoPart(t);
  m_notSaved = true;
}


void TrtmComposition::remove(int tpId) {
  if (tpId > -1 && tpId < m_tempoList.count()) {
    QTimer::singleShot(100, this, [=]{
      delete m_tempoList.takeAt(tpId);
      for (int i = tpId; i < m_tempoList.size(); ++i)
        m_tempoList[i]->setNr(i + 1);
    });
  }
}


TtempoPart* TrtmComposition::createTempoPart(int tempo) {
  auto tp = new TtempoPart(m_tempoList.size() + 1, this);
  int t = tempo < 40 || tempo > 240 ? SOUND->tempo() : tempo;
  tp->setTempos(t, t);
  connect(tp, &TtempoPart::infiniteChanged, this, &TrtmComposition::notSavedSlot);
  connect(tp, &TtempoPart::updateDuration, this, &TrtmComposition::notSavedSlot);
  return tp;
}


void TrtmComposition::notSavedSlot() {
  if (!m_notSaved) {
    for (auto tp : m_tempoList) {
      disconnect(tp, &TtempoPart::infiniteChanged, this, &TrtmComposition::notSavedSlot);
      disconnect(tp, &TtempoPart::updateDuration, this, &TrtmComposition::notSavedSlot);
    }
  }
  m_notSaved = true;
}


//#################################################################################################
//###################              TspeedHandler       ############################################
//#################################################################################################

QString getTitle(int nr) {
  return GLOB->TR(QStringLiteral("TempoPage"),
                  QStringLiteral("Rhythmic Composition")) + QString(" #%1").arg(nr, 2, 'g', -1, '0');
}


TspeedHandler::TspeedHandler(QObject* parent) :
  QObject(parent)
{
  m_fileNames = GLOB->settings()->value(QStringLiteral("rhytmicFiles"), QStringList()).toStringList();

  if (m_fileNames.isEmpty()) {
      auto comp = new TrtmComposition(this);
      comp->add();
      m_compositions << comp;
  } else {
      auto comp = new TrtmComposition(this);
      comp->readFromXMLFile(m_fileNames.first());
      m_compositions << comp;
      if (comp->title().isEmpty())
        comp->setTitle(getTitle(1));
      if (m_fileNames.size() > 1) {
        QTimer::singleShot(200, this, [=]{
            for (int f = 1; f < m_fileNames.size(); ++f) {
              auto comp = new TrtmComposition(this);
              comp->readFromXMLFile(m_fileNames[f]);
              m_compositions << comp;
              if (comp->title().isEmpty())
                comp->setTitle(getTitle(f + 1));
            }
            emit compositionsChanged();
        });
      }
  }
}


TspeedHandler::~TspeedHandler()
{
  saveCurrentComposition();
}


void TspeedHandler::saveCurrentComposition() {
  QString dataPath = QStandardPaths::standardLocations(QStandardPaths::GenericDataLocation).first();
  if (dataPath.isEmpty()) {
    // TODO: Find another path or give some debug
  } else {
      dataPath.append(QStringLiteral("/Metronomek"));
      QDir d(dataPath);
      if (!d.exists())
        d.mkpath(QStringLiteral("."));
      if (currComp()->xmlFileName().isEmpty()) {
        auto fName = QString("%1/Rhythmic_Composition_%2.metronomek.xml").arg(dataPath).arg(m_current + 1, 2, 'g', -1, '0');
        int it = 1;
        while (QFileInfo::exists(fName)) {
          fName = QString("%1/Rhythmic_Composition_%2.metronomek.xml").arg(dataPath).arg(it, 2, 'g', -1, '0');
          it++;
        }
        currComp()->setXmlFileName(fName);
      }
      currComp()->saveToXMLFile();
      m_fileNames.removeOne(currComp()->xmlFileName());
      m_fileNames.prepend(currComp()->xmlFileName());
      GLOB->settings()->setValue(QStringLiteral("rhytmicFiles"), m_fileNames);
  }
}


QString TspeedHandler::title() const {
  return m_compositions.at(m_current)->title();
}


void TspeedHandler::setTitle(const QString& t) {
  if (currComp()->title() != t) {
    currComp()->setTitle(t);
  }
}


void TspeedHandler::newComposition() {
  saveCurrentComposition();
  auto comp = new TrtmComposition(this);
  comp->add();
  m_compositions << comp;
  comp->setTitle(getTitle(m_compositions.size()));
  m_current = m_compositions.size() - 1;
  emit clearAllChanges();
  emit compositionsChanged();
  emitAllTempos();
}


void TspeedHandler::setComposition(int id) {
  if (id > -1 && id < m_compositions.count()) {
    saveCurrentComposition();
    m_current = id;
    emit clearAllChanges();
    emitAllTempos();
  }
}


void TspeedHandler::addTempo() {
  currComp()->add();
  emit appendTempoChange(currComp()->last());
}


void TspeedHandler::removeTempo(int tpId) {
  if (tpId > -1 && tpId < currComp()->partsCount()) {
    emit removeTempoChange(tpId);
    currComp()->remove(tpId);
  }
}


void TspeedHandler::emitAllTempos() {
  for (int t = 0; t < currComp()->partsCount(); ++t)
    emit appendTempoChange(currComp()->getPart(t));
}


int TspeedHandler::getTempoForBeat(int partId, int beatNr) {
  if (partId < currComp()->partsCount())
    return currComp()->getPart(partId)->getTempoForBeat(beatNr);
  else
    return 0;
}


void TspeedHandler::readFromXMLFile(const QString& xmlFile) {

}

