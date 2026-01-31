// SPDX-FileCopyrightText: 2022-2025 Tomasz Bojczuk <seelook@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

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
