/*
 * SPDX-License-Identifier: GPL-3.0-only
 * MuseScore-CLA-applies
 *
 * MuseScore
 * Music Composition & Notation
 *
 * Copyright (C) 2021 MuseScore BVBA and others
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

#ifndef MU_DOCK_MAINWINDOWPROVIDER_H
#define MU_DOCK_MAINWINDOWPROVIDER_H

#include "framework/ui/imainwindow.h"

namespace mu::dock {
class MainWindowProvider : public ui::IMainWindow
{
public:
    QMainWindow* qMainWindow() const override;
    QWindow* qWindow() const override;

    bool isFullScreen() const override;
    void toggleFullScreen() override;
    const QScreen* screen() const override;

    void requestChangeToolBarOrientation(const QString& toolBarName, framework::Orientation orientation) override;
    async::Channel<std::pair<QString, framework::Orientation> > toolBarOrientationChangeRequested() const override;

private:
    async::Channel<std::pair<QString, framework::Orientation> > m_dockOrientationChanged;
};
}

#endif // MU_DOCK_MAINWINDOWPROVIDER_H
