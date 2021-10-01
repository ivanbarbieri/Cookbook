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
    visible: true
    minimumSize: orientation == Qt.Horizontal ? height / width : width / height
    opacity: size < 1  ? 1 : 0

    contentItem: Rectangle {
        implicitWidth: 8

        radius: width / 2
        color: "grey"
    }

    background: Rectangle {
        implicitWidth: 10

        radius: width / 2
        color: "white"
    }
}
