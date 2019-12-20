/** This file is part of Metronomek                                  *
 * Copyright (C) 2019 by Tomasz Bojczuk (seelook@gmail.com)          *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

#ifndef TMETROITEM_H
#define TMETROITEM_H


#include <QtQuick/qquickitem.h>


/**
 *  C++ logic for MetronomeK
 */
class TmetroItem : public QQuickItem
{

  Q_OBJECT

public:
  TmetroItem(QQuickItem* parent = nullptr);
  ~TmetroItem() override;

signals:

};

#endif // TMETROITEM_H
