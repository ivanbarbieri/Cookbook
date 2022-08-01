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

    id: root

    property var mainWindow: Window {
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

            Column {
                anchors.fill: parent

                ItemDelegate {
                    text: qsTr("Search recipe")
                    width: parent.width
                    onClicked: {
                        stackView.pop()
                        stackView.push("SearchRecipe.qml")
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
                initialItem: "SearchRecipe.qml"
                anchors.fill: parent
            }
        }
    }

    property var selectedRecipesWindow: RecipeWindow {
        id: recipeWindow
    }
}

//import QtQuick
//import QtQuick.Controls

//ApplicationWindow {
//    width: 400
//    height: 400
//    visible: true

//    required property QtObject _recipesList
//    required property QtObject _searchRecipe
//    required property QtObject _selectedRecipes

//    Button {
//        id: button
//        text: "A Special Button"
//        background: Rectangle {
//            implicitWidth: 100
//            implicitHeight: 40
//            color: button.down ? "#d6d6d6" : "#f6f6f6"
//            border.color: "#26282a"
//            border.width: 1
//            radius: 4
//        }
//    }
//}
