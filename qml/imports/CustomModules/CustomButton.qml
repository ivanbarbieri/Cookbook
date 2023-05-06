import qml.imports.Constants

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic

Basic.Button {
    id: control

    property alias labelColor: label.color

    property alias radius: bg.radius
    property alias bgColor: bg.color
    property alias bgBorderWidth: bg.border.width
    property alias bgBorderColor: bg.border.color
    property alias bgOpacity: bg.opacity

    contentItem: IconLabel {
        id: label

        spacing: control.spacing
        mirrored: control.mirrored
        display: control.display

        icon: control.icon
        text: control.text
        font: control.font
        color: control.down ? Colors.white : Colors.bgSecondary
    }

    background: Rectangle {
        id: bg

        color: hovered ? Colors.lightGrey : Colors.white

        border.width: hovered ? 2 : 0
        border.color: control.down ? Colors.white : hovered ? Colors.bgSecondary : Colors.lightGrey

        radius: Constants.radius
    }
}
