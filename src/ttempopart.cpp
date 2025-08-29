/** This file is part of Metronomek                                  *
 * Copyright (C) 2021 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#include "ttempopart.h"
#include "tsound.h"

#include <QtCore/qdebug.h>
#include <QtCore/qxmlstream.h>

TtempoPart::TtempoPart(int partNr, QObject *parent)
    : QObject(parent)
    , m_nr(partNr)
{
}

TtempoPart::~TtempoPart()
{
}

void TtempoPart::setNr(int nr)
{
    if (nr != m_nr) {
        m_nr = nr;
        emit nrChanged();
        emit tempoTextChanged();
    }
}

void TtempoPart::setInitTempo(int it)
{
    if (it != m_initTempo) {
        m_initTempo = it;
        calculateDuration();
        emit initTempoChanged();
        emit updateDuration();
        emit tempoTextChanged();
        if (m_initTempo != m_targetTempo && m_infinite) {
            m_infinite = false;
            emit infiniteChanged();
        }
    }
}

void TtempoPart::setTargetTempo(int tt)
{
    if (tt != m_targetTempo) {
        m_targetTempo = tt;
        calculateDuration();
        emit targetTempoChanged();
        emit updateDuration();
        emit tempoTextChanged();
        if (m_initTempo != m_targetTempo && m_infinite) {
            m_infinite = false;
            emit infiniteChanged();
        }
    }
}

void TtempoPart::setTempos(int init, int target)
{
    setInitTempo(init);
    setTargetTempo(target);
}

void TtempoPart::setMeter(int m)
{
    if (m != m_meter) {
        m_meter = m;
        m_beats = m_bars * m_meter;
        calculateDuration();
        emit updateDuration();
        emit meterChanged();
    }
}

void TtempoPart::setBars(int brs)
{
    if (brs != m_bars) {
        m_bars = brs;
        m_beats = m_bars * m_meter;
        calculateDuration();
        emit updateDuration();
    }
}

void TtempoPart::setBeats(int bts)
{
    if (bts != m_beats) {
        m_beats = bts;
        m_bars = m_beats / m_meter + (m_beats % m_meter > 0 ? 1 : 0);
        calculateDuration();
        emit updateDuration();
    }
}

void TtempoPart::setSeconds(int sec)
{
    if (sec != m_seconds) {
        calculateDuration();
    }
}

void TtempoPart::setInfinite(bool inf)
{
    if (inf != m_infinite) {
        m_infinite = inf;
        emit infiniteChanged();
    }
}

void TtempoPart::setSpeedProfile(QEasingCurve::Type type)
{
    if (m_speedProfile.type() != type) {
        m_speedProfile.setType(type);
    }
}

int TtempoPart::getTempoForBeat(int beatNr)
{
    if (m_initTempo == m_targetTempo && m_infinite)
        return m_initTempo;

    if (beatNr > m_beats)
        return 0;

    int span = qAbs(m_initTempo - m_targetTempo);
    int tempoDiff = qRound(m_speedProfile.valueForProgress(static_cast<qreal>(beatNr) / static_cast<qreal>(m_beats)) * span);
    int dir = m_initTempo < m_targetTempo ? 1 : -1;
    return qBound(40, m_initTempo + dir * tempoDiff, 240);
}

QString TtempoPart::tempoText() const
{
    bool ch = m_initTempo != m_targetTempo;
    QString speedUpOrDown;
    if (ch) {
        if (m_initTempo < m_targetTempo)
            speedUpOrDown = tr("accelerando", "This is official, glob wide music term, so it shouldn't be translated.");
        else
            speedUpOrDown = tr("rallentando", "This is official, glob wide music term, so it shouldn't be translated.");
        speedUpOrDown.prepend(QLatin1String("  <i>("));
        speedUpOrDown.append(QLatin1String(")</i>"));
    }
    return QString("<b><font size=\"5\">%1. </b></font>    ").arg(m_nr) + tr("Tempo")
        + QString(": <b>%1%2</b>").arg(m_initTempo).arg(ch ? QString(" -> %1").arg(m_targetTempo) : QString()) + speedUpOrDown;
}

void TtempoPart::writeToXML(QXmlStreamWriter &xml)
{
    xml.writeStartElement(QLatin1String("tempoChange"));
    xml.writeTextElement(QLatin1String("init"), QString::number(m_initTempo));
    xml.writeTextElement(QLatin1String("target"), QString::number(m_targetTempo));
    xml.writeTextElement(QLatin1String("meter"), QString::number(m_meter));
    xml.writeTextElement(QLatin1String("beats"), QString::number(m_beats));
    if (m_infinite)
        xml.writeEmptyElement(QLatin1String("infinite"));
    xml.writeEndElement(); // tempo
}

void TtempoPart::readFromXML(QXmlStreamReader &xml)
{
    while (xml.readNextStartElement()) {
        if (xml.name() == QLatin1String("init"))
            m_initTempo = qBound(40, xml.readElementText().toInt(), 240);
        else if (xml.name() == QLatin1String("target"))
            m_targetTempo = qBound(40, xml.readElementText().toInt(), 240);
        else if (xml.name() == QLatin1String("meter"))
            m_meter = qBound(1, xml.readElementText().toInt(), 12);
        else if (xml.name() == QLatin1String("beats"))
            setBeats(qMax(1, xml.readElementText().toInt()));
        else if (xml.name() == QLatin1String("infinite")) {
            if (m_initTempo == m_targetTempo)
                m_infinite = true;
            else
                qDebug() << "[TtempoPart] Duration sets to infinite but initial and target tempos are different!";
            xml.skipCurrentElement();
        } else
            xml.skipCurrentElement();
    }
}

void TtempoPart::copy(TtempoPart *other)
{
    m_initTempo = other->initTempo();
    m_targetTempo = other->targetTempo();
    m_meter = other->meter();
    m_beats = other->beats();
    m_bars = other->bars();
    m_seconds = other->seconds();
    m_infinite = other->infinite();
    m_speedProfile = other->speedProfile();
}

void TtempoPart::reset()
{
    setTempos(SOUND->tempo(), SOUND->tempo());
    //   setMeter(SOUND->meter());
    setBars(1);
    setInfinite(false);
}

// #################################################################################################
// ###################                PROTECTED         ############################################
// #################################################################################################

void TtempoPart::calculateDuration()
{
    int averageTempo = (m_initTempo + m_targetTempo) / 2;
    m_seconds = qRound((60.0 / static_cast<qreal>(averageTempo)) * m_beats);
}
