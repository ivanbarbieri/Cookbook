import Constants

import QtQuick
import QtQuick.Controls

TextField {
    placeholderText: qsTr("Custom TextField")
    color: Colors.white
    selectionColor: Colors.lightGrey
    selectedTextColor: Colors.darkGrey
    font.pixelSize: 15
    layer.enabled: true
    horizontalAlignment: Text.AlignLeft
    verticalAlignment: Text.AlignVCenter
    wrapMode: Text.Wrap
    bottomPadding: 0
    topPadding: 0

    background: Rectangle {
        color: Colors.grey
        border.width: 1
        radius: Constants.radius
    }
}
