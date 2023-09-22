import qml.imports.Constants
import qml.imports.CustomModules
import Cookbook

import QtQuick
import Qt.labs.platform
import QtQuick.Controls
import QtQuick.Layouts

QtObject {
    required property QtObject _recipesList
    required property QtObject _searchRecipe
    required property QtObject _selectedRecipes
    required property QtObject _autocomplete
    required property string _buildInfos

    id: root

    property var mainWindow: Window {
        visible: true
        color: Colors.bgPrimary
        width: Constants.minWidth
        height: Constants.minHeight
        minimumWidth: Constants.minWidth
        minimumHeight: Constants.minHeight
        title: qsTr("Cookbook")

        Rectangle {
            id: leftBar
            width: 32
            color: Colors.bgSecondary
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }

            CustomButton {
                width: leftBar.width
                height: width
                text: qsTr("\u2630")
                font.pixelSize: height * 0.60
                radius: 0

                anchors {
                    left: parent.left
                    right: parent.right
                }

                onClicked: drawer.open()
            }
        }

        Drawer {
            id: drawer
            width: mainWindow.width * 0.33
            height: mainWindow.height
            background: Rectangle {
                color: Colors.bgSecondary
            }

            Column {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    bottom: parent.about
                }

                spacing: 3

                CustomButton {
                    text: qsTr("Search recipe")
                    width: parent.width
                    radius: 0

                    onClicked: {
                        stackView.pop()
                        stackView.push("SearchRecipe.qml")
                        drawer.close()
                    }
                }

                CustomButton {
                    text: qsTr("Add recipe")
                    width: parent.width
                    radius: 0

                    onClicked: {
                        stackView.pop()
                        stackView.push("AddRecipe.qml")
                        drawer.close()
                    }
                }
            }

            ColumnLayout {
                id: about

                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    margins: Constants.margin
                }

                Text {
                    text: _buildInfos
                    color: Colors.text
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    font.pixelSize: 12
                }

                Rectangle {
                    Layout.preferredHeight: 28
                    Layout.preferredWidth: height
                    radius: height/2
                    color: Colors.black

                    Image {
                        source: "icons/github-mark-white.svg"
                        sourceSize: Qt.size(parent.width, parent.height)
                        smooth: true
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        anchors.fill: parent

                        onClicked: Qt.openUrlExternally("https://github.com/ivanbarbieri/Cookbook")
                    }
                }
            }
        }

        Rectangle {
            color: Colors.bgPrimary

            anchors {
                left: leftBar.right
                right: parent.right
                top: parent.top
                bottom: parent.bottom
            }

            StackView {
                id: stackView
                initialItem: "SearchRecipe.qml"
                anchors.fill: parent
            }
        }
    }

    property var selectedRecipesWindow: RecipeWindow {
        id: recipeWindow
    }
}
