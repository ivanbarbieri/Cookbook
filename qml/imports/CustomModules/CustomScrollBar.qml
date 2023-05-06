import qml.imports.Constants

import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T

T.ScrollBar {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    padding: 2
    opacity: size < 1 ? 1 : 0
    minimumSize: orientation == Qt.Horizontal ? height / width : width / height

    contentItem: Rectangle {
        implicitHeight: 8
        implicitWidth: 8

        radius: width / 2
        color: Colors.lightGrey
    }

    background: Rectangle {
        implicitHeight: 10
        implicitWidth: 10

        radius: width / 2
        color: Colors.bgSecondary
    }
}
