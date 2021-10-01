import Constants

import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: mainWindow
    visible: true
    color: Colors.darkGrey
    width: Constants.minWidth
    height: Constants.minHeight
    minimumWidth: Constants.minWidth
    minimumHeight: Constants.minHeight
    title: qsTr("Cookbook")

    Rectangle {
        id: leftBar
        width: 32
        color: Colors.darkerGray
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }

        Button {
            width: 32
            height: width
            text: qsTr("\u2630")
            anchors.left: parent.left
            anchors.right: parent.right
            onClicked: drawer.open()
        }
    }

    Drawer {
        id: drawer
        width: mainWindow.width * 0.33
        height: mainWindow.height

        Column {
            anchors.fill: parent

            ItemDelegate {
                text: qsTr("Search Page")
                width: parent.width
                onClicked: {
                    stackView.pop()
                    stackView.push("SearchPage.qml")
                    drawer.close()
                }
            }

            ItemDelegate {
                text: qsTr("Add recipe")
                width: parent.width
                onClicked: {
                    stackView.pop()
                    stackView.push("AddRecipe.qml")
                    drawer.close()
                }
            }
        }
    }

    Rectangle {
        color: Colors.darkGrey
        anchors {

            left: leftBar.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }

        StackView {
            id: stackView
            initialItem: "SearchPage.qml"
            anchors.fill: parent
        }
    }
}
