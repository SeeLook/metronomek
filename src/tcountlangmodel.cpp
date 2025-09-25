/** This file is part of Metronomek                                  *
 * Copyright (C) 2022-2025 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#include "tcountlangmodel.h"

using namespace Qt::Literals::StringLiterals;

TcountLangModel::TcountLangModel(int currLang, QObject *parent)
    : QAbstractListModel(parent)
{
    m_allLocales = QLocale::matchingLocales(QLocale::AnyLanguage, QLocale::AnyScript, QLocale::AnyCountry);
    int cnt = 0;
    while (cnt < m_allLocales.size()) {
        QLocale &locale = m_allLocales[cnt];
        if (locale.language() < 2) { // skip 'default' and 'C' types
            m_allLocales.removeAt(cnt);
            continue;
        }
        if (locale.languageToString(locale.language()).isEmpty()) {
            m_allLocales.removeAt(cnt);
            continue;
        }
        auto name = locale.nativeLanguageName();
        int i = cnt + 1;
        while (i < m_allLocales.size()) {
            if (name == m_allLocales[i].nativeLanguageName())
                m_allLocales.removeAt(i);
            else
                i++;
        }
        cnt++;
    }
    int lId = 0;
    for (auto &l : m_allLocales) {
        if (l.language() == currLang) {
            m_currentLangId = lId;
            break;
        }
        lId++;
    }
}

int TcountLangModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_allLocales.count();
}

QVariant TcountLangModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() && index.row() < m_allLocales.count())
        return QVariant();

    if (role == Qt::DisplayRole) {
        const QLocale &locale = m_allLocales[index.row()];
        if (!locale.nativeLanguageName().isEmpty())
            return locale.languageToString(locale.language()) + " / "_L1 + locale.nativeLanguageName();
    }
    if (role == Qt::UserRole) {
        return m_allLocales[index.row()].language();
    }
    return QVariant();
}

QHash<int, QByteArray> TcountLangModel::roleNames() const
{
    return {{Qt::DisplayRole, "langName"}, {Qt::UserRole, "langID"}};
}

void TcountLangModel::setCurrentLangId(int cr)
{
    if (m_currentLangId == cr)
        return;
    m_currentLangId = cr;
    emit currentLangIdChanged();
}
