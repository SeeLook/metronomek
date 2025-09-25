/** This file is part of Metronomek                                  *
 * Copyright (C) 2022-2025 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#pragma once

#include <QtCore/qabstractitemmodel.h>
#include <QtCore/qlocale.h>
#include <QtQml/qqmlregistration.h>

class TcountLangModel : public QAbstractListModel
{
    Q_OBJECT
    QML_NAMED_ELEMENT(CountLangModel)
    QML_UNCREATABLE("")

    Q_PROPERTY(int currentLangId READ currentLangId WRITE setCurrentLangId NOTIFY currentLangIdChanged)

public:
    explicit TcountLangModel(int currLang, QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    QHash<int, QByteArray> roleNames() const override;

    int currentLangId() const { return m_currentLangId; }
    void setCurrentLangId(int cr);

Q_SIGNALS:
    void currentLangIdChanged();

private:
    QVector<QLocale> m_allLocales;
    int m_currentLangId = 0;
};
