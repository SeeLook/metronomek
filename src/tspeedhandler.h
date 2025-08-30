/** This file is part of Metronomek                                  *
 * Copyright (C) 2021-2025 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#ifndef TSPEEDHANDLER_H
#define TSPEEDHANDLER_H

#include "ttempopart.h"
#include <QtCore/qobject.h>
#include <QtQml/qqmlregistration.h>

class TtempoPart;

/**
 * @class TrtmComposition - RHYTHMIC COMPOSITION.
 * Every single change is described by @class TtempoPart
 * and @p m_tempoList is the list of those changes.
 */
class TrtmComposition : public QObject
{
    Q_OBJECT
    QML_NAMED_ELEMENT(Composition)
    QML_UNCREATABLE("")

    Q_PROPERTY(QString title READ title WRITE setTitle NOTIFY titleChanged)
    Q_PROPERTY(QList<TtempoPart *> parts READ parts NOTIFY partsChanged)
    Q_PROPERTY(int partsCount READ partsCount NOTIFY partsChanged)

public:
    TrtmComposition(QObject *parent = nullptr);
    ~TrtmComposition() override;

    QString title() const { return m_title; }
    void setTitle(const QString &t);

    /**
     * Corresponding XML file
     */
    QString xmlFileName() const { return m_xmlFileName; }
    void setXmlFileName(const QString &xml) { m_xmlFileName = xml; }

    QList<TtempoPart *> parts() { return m_tempoList; }
    int partsCount() const { return m_tempoList.count(); }
    Q_INVOKABLE TtempoPart *getPart(int id) { return id > -1 && id < partsCount() ? m_tempoList[id] : nullptr; }
    TtempoPart *first() { return m_tempoList.first(); }
    TtempoPart *last() { return m_tempoList.last(); }

    /**
     * Stores rhythmic composition data into XML file
     * @p xmlName - which can be empty string
     * - then @p m_xmlFileName is used (if set)
     */
    void saveToXMLFile(const QString &xmlName = QString());

    /**
     * Reads from @p xmlFile
     * Also stores this name into @p m_xmlFileName.
     */
    void readFromXMLFile(const QString &xmlName);

    void add();
    void remove(int tpId);

    bool notSaved() const { return m_notSaved; }

signals:
    void titleChanged();
    void partsChanged();

protected:
    TtempoPart *createTempoPart(int tempo = 0);
    void notSavedSlot();

private:
    QString m_title;
    QString m_xmlFileName;
    QList<TtempoPart *> m_tempoList;
    bool m_notSaved = true;
};

/**
 * @class TspeedHandler manages tempo changes.
 * Stores @p TrtmComposition list
 */
class TspeedHandler : public QObject
{
    Q_OBJECT
    QML_NAMED_ELEMENT(SpeedHandler)
    QML_UNCREATABLE("")

    Q_PROPERTY(QList<TrtmComposition *> compositions READ compositions NOTIFY compositionsChanged)
    Q_PROPERTY(TrtmComposition *currComp READ currComp NOTIFY currCompChanged)
    Q_PROPERTY(qreal currCompId READ currCompId WRITE setComposition NOTIFY currCompChanged)

public:
    TspeedHandler(QObject *parent = nullptr);
    ~TspeedHandler() override;

    QString title() const;
    Q_INVOKABLE void setTitle(const QString &t);

    Q_INVOKABLE QString getTitle(int nr) const;

    QList<TrtmComposition *> compositions() { return m_compositions; }

    /**
     * Actually selected composition
     */
    TrtmComposition *currComp() { return m_compositions[m_current]; }
    int currCompId() const { return m_current; }

    Q_INVOKABLE void newComposition();
    Q_INVOKABLE void duplicateComposition();
    //   Q_INVOKABLE void resetComposition(); NOTE: preformed using QML only
    Q_INVOKABLE void removeComposition(bool alsoDeleteFile = false);

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

    void saveToXMLFile(const QString &xmlFile);
    void readFromXMLFile(const QString &xmlFile);

    void saveCurrentComposition();

signals:
    void appendTempoChange(TtempoPart *tp);
    void removeTempoChange(int tpId);
    void clearAllChanges();
    void compositionsChanged();
    void currCompChanged();

private:
    QStringList m_fileNames;
    QList<TrtmComposition *> m_compositions;
    int m_current = 0;
};

#endif // TSPEEDHANDLER_H
