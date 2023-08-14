import qml.imports.Constants
import qml.imports.CustomModules
import Cookbook

import QtQuick
import QtQuick.Controls

Item {
    readonly property int margin: 10

    id: root 

    implicitHeight: Constants.minHeight
    implicitWidth: Constants.minWidth


    // FORM recipe name + list of ingredient names
    SearchRecipeForm {
        id: form

        width: 155
        anchors {
            left: parent.left
            bottom: parent.bottom
            top: parent.top
            margins: 10
        }
    }


    ListView {
        id: recipesList
        clip: true
        spacing: 5
        anchors {
            left: form.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            leftMargin: 10
        }

        ScrollBar.vertical: CustomScrollBar {
            id: recipeScrollBar
        }

        model: _recipesList

        delegate: Rectangle {
            id: recipe

            height: 150
            width: recipesList.width - (recipeScrollBar.opacity ? recipeScrollBar.width : 0)
            radius: Constants.radius
            color: Colors.bgSecondary

            Rectangle {
                id: toolBar

                height: 30
                color: Colors.bgSecondary
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }

                Text {
                    id: recipeTitle

                    text: _recipesList.recipe(index).title ?? ""
                    style: Text.Raised
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pointSize: 16
                    color: Colors.text
                    elide: Text.ElideRight
                    anchors {
                        left: parent.left
                        right: openRecipe.left
                        verticalCenter: parent.verticalCenter
                        rightMargin: root.margin
                    }
                }

                CustomButton {
                    id: openRecipe

                    icon.source: "icons/open-in-popup.svg"
                    icon.color: openRecipe.down ? Colors.white : Colors.bgSecondary
                    anchors {
                        right: parent.right;
                        top: parent.top;
                        bottom: parent.bottom;
                    }
                    onClicked: {
                        recipeWindow.visible = true
                        _recipesList.recipe(index).getIngredients()
                        _selectedRecipes.appendRecipe(_recipesList.recipe(index).clone())
                    }
                }
            }

            Image {
                id: recipeImage

                width: (recipeImage.height - root.margin) * 16/9
                fillMode: Image.PreserveAspectFit
                source: _recipesList.recipe(index).pathImage ? _recipesList.recipe(index).pathImage : "icons/placeholder.svg"
                anchors {
                    left: parent.left
                    top: toolBar.bottom
                    bottom: parent.bottom
                    margins: root.margin
                }
                asynchronous : true

                onStatusChanged: {
                    if (recipeImage.status === Image.Error || recipeImage.status === Image.Null) {
                        source = "icons/placeholder.svg"
                    }
                }
            }

            Column {
                id: box

                anchors {
                    left: recipeImage.right
                    top: recipeImage.top
                    bottom: recipeImage.bottom
                    leftMargin: root.margin
                    rightMargin: root.margin
                }

                Text {
                    text: qsTr("Preparaton time")
                    color: Colors.text
                }

                Text {
                    id: preparationTime
                    text: _recipesList.recipe(index).preparationTime  ?? 0
                    color: Colors.text
                    wrapMode: Text.Wrap
                }

                Text {
                    text: qsTr("Coooking time")
                    color: Colors.text
                }

                Text {
                    id: cookingTime
                    text: _recipesList.recipe(index).cookingTime  ?? 0
                    color: Colors.text
                    wrapMode: Text.Wrap
                }

                Text {
                    text: qsTr("Yield")
                    color: Colors.text
                }

                Text {
                    id: yield

                    text: _recipesList.recipe(index).yield ?? 0
                    color: Colors.text
                    wrapMode: Text.Wrap
                }
            }


            ScrollView {
                id: scrollInstruction

                width: (parent.width + anchors.rightMargin + anchors.leftMargin) / 2
                clip: true
                rightPadding: instructionsScrollBar.width
                leftPadding: 0
                anchors {
                    left: box.right
                    right: parent.right;
                    top: toolBar.bottom
                    bottom: parent.bottom
                    margins: root.margin
                }

                ScrollBar.vertical: CustomScrollBar {
                    id: instructionsScrollBar

                    anchors {
                        top: scrollInstruction.top
                        right: scrollInstruction.right
                        bottom: scrollInstruction.bottom
                    }
                }

                CustomTextArea {
                    id: instructions

                    text: _recipesList.recipe(index).instructions ?? ""
                    readOnly: true
                }
            }
        }
    }
}




