import qml.imports.Constants
import qml.imports.CustomModules
import Cookbook

import QtQuick
import QtQuick.Controls

Item {
    readonly property int margin: 10

    id: root
    width: Constants.minWidth
    height: Constants.minHeight

    // FORM recipe name + list of ingredient names
    SearchRecipeForm {
        id: form
        width: 155
        anchors {
            left: parent.left
            bottom: parent.bottom
            top: parent.top
        }
    }


    ListView {
        id: recipesList
        clip: true

        anchors {
            left: form.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }

        ScrollBar.vertical: CustomScrollBar {
            id: recipeScrollBar
        }

        model: _recipesList

        delegate: Item {
            height: 150
            width: recipesList.width - recipeScrollBar.width
            id: recipe

            ToolBar {
                id: toolBar
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

                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                    }
                }

                Button {
                    icon.source: "icons/placeholder.svg"

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
                height: recipe.height
                fillMode: Image.PreserveAspectFit
                source: _recipesList.recipe(index).pathImage ? _recipesList.recipe(index).pathImage : "icons/placeholder.svg"

                anchors {
                    left: parent.left
                    top: toolBar.bottom
                    bottom: parent.bottom
                    margins: root.margin
                }

                asynchronous : true
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
                    color: Colors.white
                }

                Text {
                    id: preparationTime
                    text: _recipesList.recipe(index).preparationTime  ?? 0
                    color: Colors.white
                    wrapMode: Text.Wrap
                }

                Text {
                    text: qsTr("Coooking time")
                    color: Colors.white
                }

                Text {
                    id: cookingTime
                    text: _recipesList.recipe(index).cookingTime  ?? 0
                    color: Colors.white
                    wrapMode: Text.Wrap
                }

                Text {
                    text: qsTr("Yield")
                    color: Colors.white
                }

                Text {
                    id: yield
                    text: _recipesList.recipe(index).yield ?? 0
                    color: Colors.white
                    wrapMode: Text.Wrap
                }
            }


            ScrollView {
                id: scrollInstruction
                width: (parent.width + anchors.rightMargin + anchors.leftMargin)/2
                clip: true

                anchors {
                    left: box.right
                    right: parent.right;
                    top: toolBar.bottom
                    bottom: parent.bottom
                    margins: root.margin
                }

                ScrollBar.vertical: CustomScrollBar {
                    anchors.top: scrollInstruction.top
                    anchors.right: scrollInstruction.right
                    anchors.bottom: scrollInstruction.bottom
                }

                TextArea {
                    id: instructions
                    text: _recipesList.recipe(index).instructions ?? ""
                    readOnly: true
                    color: Colors.white
                    selectionColor: Colors.darkGrey
                    selectedTextColor: Colors.white
                    wrapMode: Text.Wrap
                    font.pixelSize: 15
                    background: Rectangle {
                        color: Colors.grey
                        radius: Constants.radius
                    }
                }
            }
        }
    }
}




