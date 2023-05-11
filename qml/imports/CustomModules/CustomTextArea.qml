import qml.imports.Constants

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic

Basic.TextArea {
    id: control

    property alias bgColor: bg.color
    property alias bgRadius: bg.radius

    placeholderTextColor: Colors.placeholderText
    color: Colors.text
    selectionColor: Colors.selection
    selectedTextColor: Colors.selectedText
    wrapMode: Text.Wrap
    font.pixelSize: Constants.pixelSize

    background: Rectangle {
        id: bg

        color: Colors.bgText
        radius: Constants.radius
    }
}
