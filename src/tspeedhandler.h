/** This file is part of Metronomek                                  *
 * Copyright (C) 2021 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#ifndef TSPEEDHANDLER_H
#define TSPEEDHANDLER_H


#include <QtCore/qobject.h>


class TtempoPart;


/**
 * @class TrtmComposition - RHYTHMIC COMPOSITION.
 * Every single change is described by @class TtempoPart
 * and @p m_tempoList is the list of those changes.
 */
class TrtmComposition : public QObject
{

  Q_OBJECT

public:
  TrtmComposition(QObject* parent = nullptr);
  ~TrtmComposition() override;

  QString title() const { return m_title; }
  void setTitle(const QString& t);

      /**
       * Corresponding XML file
       */
  QString xmlFileName() const { return m_xmlFileName; }
  void setXmlFileName(const QString& xml) { m_xmlFileName = xml; }

  int partsCount() const { return m_tempoList.count(); }
  TtempoPart* getPart(int id) { return id < partsCount() ? m_tempoList[id] : nullptr; }
  TtempoPart* first() { return m_tempoList.first(); }
  TtempoPart* last() { return m_tempoList.last(); }

      /**
       * Stores rhythmic composition data into XML file
       * @p xmlName - which can be empty string
       * - then @p m_xmlFileName is used (if set)
       */
  void saveToXMLFile(const QString& xmlName = QString());

      /**
       * Reads from @p xmlFile
       * Also stores this name into @p m_xmlFileName.
       */
  void readFromXMLFile(const QString& xmlName);

  void add();
  void remove(int tpId);

protected:
  TtempoPart* createTempoPart(int tempo = 0);

private:
  QString                             m_title;
  QString                             m_xmlFileName;
  QList<TtempoPart*>                  m_tempoList;
};


/**
 * @class TspeedHandler manages tempo changes.
 * Stores @p TrtmComposition list
 */
class TspeedHandler : public QObject
{

  Q_OBJECT

  Q_PROPERTY(QString title READ title WRITE setTitle NOTIFY titleChanged)
  Q_PROPERTY(QStringList titleModel READ titleModel NOTIFY titleModelChanged)

public:
  TspeedHandler(QObject* parent = nullptr);
  ~TspeedHandler() override;

  QString title() const;
  void setTitle(const QString& t);

  QStringList titleModel() const { return m_titleModel; }

      /**
       * Actually selected composition
       */
  TrtmComposition* currComp() { return m_compositions[m_current]; }

  Q_INVOKABLE void newComposition();
//   Q_INVOKABLE void duplicate();
//   Q_INVOKABLE void reset();
//   Q_INVOKABLE void removeComposition();

  Q_INVOKABLE void setComposition(int id);

      /**
       * Adds new, default tempo part to the list
       */
  Q_INVOKABLE void addTempo();

  Q_INVOKABLE void removeTempo(int tpId);

      /**
       * Invokes @p appendTempoChange() signal
       * for every tempo part in the list
       */
  Q_INVOKABLE void emitAllTempos();

  int getTempoForBeat(int partId, int beatNr);

  void saveToXMLFile(const QString& xmlFile);
  void readFromXMLFile(const QString& xmlFile);

  void saveCurrentComposition();

signals:
  void appendTempoChange(TtempoPart* tp);
  void removeTempoChange(int tpId);
  void clearAllChanges();
  void titleChanged();
  void titleModelChanged();

private:
  QStringList                         m_fileNames;
  QList<TrtmComposition*>             m_compositions;
  QStringList                         m_titleModel;
  int                                 m_current = 0;

};

#endif // TSPEEDHANDLER_H
