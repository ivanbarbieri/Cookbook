import qml.imports.Constants

import QtQuick
import QtQuick.Controls

Button {
    id: root

    background: Rectangle {
        color: root.down ? Colors.lightGrey : Colors.white
        border.width: hovered ? 3 : 1
        radius: 5
    }
}
