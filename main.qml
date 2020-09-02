import QtQuick 2.9
import QtQuick.Controls 2.2

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 640
    height: 480
    title: qsTr("Cookbook")

    header: ToolBar {
        contentHeight: toolButton.implicitHeight

        ToolButton {
            id: toolButton
            text: "\u2630"
            font.pixelSize: Qt.application.font.pixelSize * 1.6
            onClicked: drawer.open()
        }

        Label {
            id: labelMainBar
            text: "Search Page"
            anchors.centerIn: parent
        }
    }

    Drawer {
        id: drawer
        width: mainWindow.width * 0.66
        height: mainWindow.height

        Column {
            anchors.fill: parent

            ItemDelegate {
                text: qsTr("Search Page")
                width: parent.width
                onClicked: {
                    labelMainBar.text = "Search Page"
                    stackView.push("SearchPage.qml")
                    drawer.close()
                }
            }
        }
    }

    StackView {
        id: stackView
        initialItem: "SearchPage.qml"
        anchors.fill: parent
    }
}
