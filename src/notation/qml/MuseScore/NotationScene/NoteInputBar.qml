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
import QtQuick 2.12
import QtQuick.Controls 2.12

import MuseScore.NotationScene 1.0
import MuseScore.UiComponents 1.0
import MuseScore.Ui 1.0

Rectangle {
    id: root

    property alias orientation: gridView.orientation

    property alias navigation: keynavSub

    color: ui.theme.backgroundPrimaryColor

    QtObject {
        id: privatesProperties

        property bool isHorizontal: orientation === Qt.Horizontal
    }

    NavigationPanel {
        id: keynavSub
        name: "NoteInputBar"
    }

    NoteInputBarModel {
        id: noteInputModel
    }

    Component.onCompleted: {
        noteInputModel.load()
    }

    GridViewSectional {
        id: gridView
        anchors.fill: parent

        sectionRole: "sectionRole"

        rowSpacing: 6
        columnSpacing: 6

        cellWidth: 36
        cellHeight: cellWidth

        model: noteInputModel

        sectionDelegate: SeparatorLine {
            orientation: gridView.isHorizontal ? Qt.Vertical : Qt.Horizontal
            visible: itemIndex !== 0
        }

        itemDelegate: FlatButton {
            id: btn
            property var item: Boolean(itemModel) ? itemModel : null
            property var hasSubitems: Boolean(item) && item.subitemsRole.length !== 0

            normalStateColor: Boolean(item) && item.checkedRole ? ui.theme.accentColor : "transparent"

            icon: Boolean(item) ? item.iconRole : IconCode.NONE
            hint: Boolean(item) ? item.hintRole : ""

            iconFont: ui.theme.toolbarIconsFont

            navigation.panel: keynavSub
            navigation.name: hint
            navigation.order: Boolean(item) ? item.orderRole : 0
            isClickOnKeyNavTriggered: false
            navigation.onTriggered: {
                if (hasSubitems && item.showSubitemsByPressAndHoldRole) {
                    btn.pressAndHold()
                } else {
                    btn.clicked()
                }
            }

            pressAndHoldInterval: 200

            width: gridView.cellWidth
            height: gridView.cellWidth

            onClicked: {
                if (menuLoader.isMenuOpened() || (hasSubitems && !item.showSubitemsByPressAndHoldRole)) {
                    menuLoader.toggleOpened(item.subitemsRole, btn.navigation)
                    return
                }

                Qt.callLater(noteInputModel.handleAction, item.codeRole)
            }

            onPressAndHold: {
                if (menuLoader.isMenuOpened() || !hasSubitems) {
                    return
                }

                menuLoader.toggleOpened(item.subitemsRole, btn.navigation)
            }

            Canvas {

                visible: Boolean(item) && item.showSubitemsByPressAndHoldRole

                width: 4
                height: 4

                anchors.margins: 2
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                onPaint: {
                    const ctx = getContext("2d");
                    ctx.fillStyle = ui.theme.fontPrimaryColor;
                    ctx.moveTo(width, 0);
                    ctx.lineTo(width, height);
                    ctx.lineTo(0, height);
                    ctx.closePath();
                    ctx.fill();
                }
            }

            StyledMenuLoader {
                id: menuLoader
                onHandleAction: noteInputModel.handleAction(actionCode, actionIndex)
            }
        }
    }

    FlatButton {
        id: customizeButton

        anchors.margins: 8

        width: gridView.cellWidth
        height: gridView.cellHeight

        icon: IconCode.CONFIGURE
        iconFont: ui.theme.toolbarIconsFont
        normalStateColor: "transparent"
        navigation.panel: keynavSub
        navigation.order: 100

        onClicked: {
            api.launcher.open("musescore://notation/noteinputbar/customise")
        }
    }

    states: [
        State {
            when: privatesProperties.isHorizontal
            PropertyChanges {
                target: gridView
                sectionWidth: 1
                sectionHeight: root.height
                rows: 1
                columns: gridView.noLimit
            }

            AnchorChanges {
                target: customizeButton
                anchors.right: root.right
                anchors.verticalCenter: root.verticalCenter
            }
        },
        State {
            when: !privatesProperties.isHorizontal
            PropertyChanges {
                target: gridView
                sectionWidth: root.width
                sectionHeight: 1
                rows: gridView.noLimit
                columns: 2
            }

            AnchorChanges {
                target: customizeButton
                anchors.bottom: root.bottom
                anchors.right: root.right
            }
        }
    ]
}
