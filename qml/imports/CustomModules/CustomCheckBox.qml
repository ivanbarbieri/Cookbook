import qml.imports.Constants

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic as Basic

Basic.CheckBox {
    id: control

    text: qsTr("CheckBox")
    checked: true

    implicitHeight: Constants.height

    indicator: Rectangle {
        implicitWidth: parent.height
        implicitHeight: parent.height
        y: parent.height / 2 - height / 2
        radius: height / 2
        color: hovered ? Colors.lightGrey : Colors.white

        border.width: hovered ? 2 : 0
        border.color: down ? Colors.white : hovered ? Colors.bgSecondary : Colors.lightGrey

        opacity: hovered ? 0.5 : 1

        Text {
            width: control.height / 2
            height: control.height / 2
            text: "\u2714"
            minimumPixelSize: height
            color: control.down ? Colors.white : Colors.bgSecondary
            visible: control.checked

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors {
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
            }

        }
    }

    contentItem: Text {
        text: control.text
        color: Colors.text
        font.pixelSize: 15
        verticalAlignment: Text.AlignVCenter
        leftPadding: control.indicator.width
    }
}
