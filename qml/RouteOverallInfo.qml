/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2014 Osmo Salomaa, 2018-2019 Rinigus, 2019 Purism SPC
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import "."
import "platform"

Item {
    // Distance and time remaining + total
    id: infoLayout
    anchors.left: parent.left
    anchors.leftMargin: app.styler.themeHorizontalPageMargin
    anchors.right: parent.right
    anchors.rightMargin: app.styler.themeHorizontalPageMargin
    height: {
        if (!visible) return 0;
        if (willFit) return lr1.height + lr2.height + app.styler.themePaddingMedium;
        return lr1.height + lr2.height + t1.height + t2.height + 3*app.styler.themePaddingMedium;
    }
    states: [
        State {
            when: !infoLayout.willFit
            AnchorChanges {
                target: d1
                anchors.right: infoLayout.right
            }
            PropertyChanges {
                target: d1
                anchors.rightMargin: 0
                width: parent.width-infoLayout.col1w-app.styler.themePaddingLarge
            }
            AnchorChanges {
                target: t1
                anchors.baseline: undefined
                anchors.right: parent.right
                anchors.top: d1.bottom
            }
            PropertyChanges {
                target: t1
                width: parent.width
                anchors.topMargin: app.styler.themePaddingMedium
            }
            AnchorChanges {
                target: d2
                anchors.right: infoLayout.right
            }
            PropertyChanges {
                target: d2
                anchors.rightMargin: 0
                width: parent.width-infoLayout.col1w-app.styler.themePaddingLarge
            }
            AnchorChanges {
                target: t2
                anchors.baseline: undefined
                anchors.right: parent.right
                anchors.top: d2.bottom
            }
            PropertyChanges {
                target: t2
                width: parent.width
                anchors.topMargin: app.styler.themePaddingMedium
            }
        }
    ]

    property bool activeColors: false
    property int  col1w: Math.max(lr1.implicitWidth, lr2.implicitWidth)
    property int  col2w: Math.max(d1.implicitWidth, d2.implicitWidth)
    property int  col3w: Math.max(t1.implicitWidth, t2.implicitWidth)
    property bool willFit: width - app.styler.themePaddingLarge*2- col1w - col2w - col3w > 0

    // Row 1
    LabelPL {
        id: lr1
        anchors.left: parent.left
        anchors.top: parent.top
        color: activeColors ? app.styler.themeSecondaryColor : app.styler.themeSecondaryHighlightColor
        horizontalAlignment: Text.AlignRight
        font.pixelSize: app.styler.themeFontSizeMedium
        text: app.tr("Remaining")
        width: infoLayout.col1w
    }
    LabelPL {
        id: d1
        anchors.baseline: lr1.baseline
        anchors.right: t1.left
        anchors.rightMargin: app.styler.themePaddingLarge
        color: activeColors ? app.styler.themePrimaryColor : app.styler.themeHighlightColor
        horizontalAlignment: Text.AlignRight
        font.pixelSize: app.styler.themeFontSizeMedium
        text: app.navigationStatus.destDist
        width: infoLayout.col2w
    }
    LabelPL {
        id: t1
        anchors.baseline: lr1.baseline
        anchors.right: parent.right
        color: activeColors ? app.styler.themePrimaryColor : app.styler.themeHighlightColor
        horizontalAlignment: Text.AlignRight
        font.pixelSize: app.styler.themeFontSizeMedium
        text: app.navigationStatus.destTime
        width: infoLayout.col3w
    }

    // Row 2
    LabelPL {
        id: lr2
        anchors.left: parent.left
        anchors.top: t1.bottom
        anchors.topMargin: app.styler.themePaddingMedium
        color: activeColors ? app.styler.themeSecondaryColor : app.styler.themeSecondaryHighlightColor
        horizontalAlignment: Text.AlignRight
        font.pixelSize: app.styler.themeFontSizeMedium
        text: app.tr("Total")
        width: infoLayout.col1w
    }
    LabelPL {
        id: d2
        anchors.baseline: lr2.baseline
        anchors.right: t2.left
        anchors.rightMargin: app.styler.themePaddingLarge
        color: activeColors ? app.styler.themePrimaryColor : app.styler.themeHighlightColor
        horizontalAlignment: Text.AlignRight
        font.pixelSize: app.styler.themeFontSizeMedium
        text: app.navigationStatus.totalDist
        width: infoLayout.col2w
    }
    LabelPL {
        id: t2
        anchors.baseline: lr2.baseline
        anchors.right: parent.right
        color: activeColors ? app.styler.themePrimaryColor : app.styler.themeHighlightColor
        horizontalAlignment: Text.AlignRight
        font.pixelSize: app.styler.themeFontSizeMedium
        text: app.navigationStatus.totalTime
        width: infoLayout.col3w
    }
}