import Constants

import QtQuick
import QtQuick.Controls

TextField {
    selectionColor: Colors.darkGrey
    selectedTextColor: Colors.white
    font.pixelSize: 15
    horizontalAlignment: Text.AlignLeft
    verticalAlignment: Text.AlignVCenter
    wrapMode: Text.Wrap
    bottomPadding: 2
    topPadding: 2
    leftPadding: Constants.radius
    rightPadding: Constants.radius

    background: Rectangle {
        color: Colors.grey
        border.width: 1
        radius: Constants.radius
    }
}
