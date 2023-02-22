import qml.imports.Constants

import QtQuick
import QtQuick.Controls

ToolTip {
    property alias bgColor: bg.color

    id: root
    timeout: 2500

    contentItem: Text {
        text: root.text
    }

    background: Rectangle {
        id: bg
        width: root.width
        color: Colors.grey
        border.width: 3
        radius: Constants.radius
    }
}
