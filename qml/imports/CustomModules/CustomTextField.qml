import qml.imports.Constants

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic

Basic.TextField {
    id: control

    property alias cursorShape: mouseArea.cursorShape

    color: Colors.text
    selectionColor: Colors.selection
    selectedTextColor: Colors.selectedText
    placeholderTextColor: Colors.placeholderText
    font.pixelSize: Constants.pixelSize
    horizontalAlignment: Text.AlignLeft
    verticalAlignment: Text.AlignVCenter
    wrapMode: Text.Wrap
    bottomPadding: 2
    topPadding: 2
    leftPadding: control.radius
    rightPadding: control.radius
    selectByMouse: true

    MouseArea {
        id: mouseArea

        acceptedButtons: Qt.NoButton
        cursorShape: Qt.IBeamCursor
        anchors.fill: parent

        onClicked: control.forceActiveFocus()
    }

    background: Rectangle {
        color: Colors.bgText
        border.width: 1
        radius: Constants.radius
    }
}
