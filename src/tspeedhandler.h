/** This file is part of Metronomek                                  *
 * Copyright (C) 2021 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#ifndef TSPEEDHANDLER_H
#define TSPEEDHANDLER_H


#include <QtCore/qobject.h>


class TtempoPart;


/**
 * @class TspeedHandler manages tempo changes.
 * Every single change is described by @class TtempoPart
 * and @p m_tempoList is the list of those changes.
 */
class TspeedHandler : public QObject
{

  Q_OBJECT

public:
  TspeedHandler(QObject* parent = nullptr);
  ~TspeedHandler() override;

      /**
       * Adds new, default tempo part to the list
       */
  Q_INVOKABLE void add();

  Q_INVOKABLE void remove(int tpId);

      /**
       * Invokes @p appendTempoChange() signal
       * for every tempo part in the list
       */
  Q_INVOKABLE void emitAllTempos();

  int getTempoForBeat(int partId, int beatNr);

  void saveToXMLFile(const QString& xmlFile);
  void readFromXMLFile(const QString& xmlFile);

signals:
  void appendTempoChange(TtempoPart* tp);
  void removeTempoChange(int tpId);

protected:
  TtempoPart* createTempoPart(int tempo = 0);

private:
  QList<TtempoPart*>                  m_tempoList;

};

#endif // TSPEEDHANDLER_H
