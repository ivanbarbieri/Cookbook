import Constants
import CustomModules

import QtQuick
import QtQuick.Controls

Item {
    id: root
    width: Constants.minWidth
    height: Constants.minHeight

    // FORM recipe name + list of ingredient names
    Item {
        id: form
        width: 155
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.top: parent.top

        CustomButton {
            id: searchButton
            text: 'Search'
            width: parent.width
            height: 23

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }

            onClicked: _searchRecipe.search(nameRecipe.text.toString())
        }

        CustomTextField {
            id: nameRecipe
            placeholderText: qsTr("Name recipe")
            width: parent.width/2
            height: 23 * text.lineCount
            horizontalAlignment: Text.AlignLeft

            anchors {
                left: parent.left
                right: parent.right
                top: searchButton.bottom
            }
        }

        CustomButton {
            id: addIngredientButton
            text: 'Add ingredient'
            height: 23

            anchors {
                left: parent.left
                right: parent.right
                top: nameRecipe.bottom
            }

            onClicked: _searchRecipe.appendIngredient()
        }

        ListView {
            id: listView
            spacing: 5
            clip: true

            anchors {
                left: parent.left
                right: parent.right
                top: addIngredientButton.bottom
                bottom: parent.bottom
                topMargin: 2.5
            }

            ScrollBar.vertical: CustomScrollBar {
                id: scrollBar
            }

            model: _searchRecipe

            delegate: Item {
                id: ingredientForm
                width: listView.width - scrollBar.width
                height: ingredient.height

                anchors {
                    rightMargin: 5
                }

                CustomTextField {
                    id: ingredient
                    placeholderText: qsTr("Ingredient")
                    width: parent.width/2
                    height: 23 * text.lineCount
                    horizontalAlignment: Text.AlignLeft

                    anchors {
                        left: parent.left
                        right: removeButton.left
                        rightMargin: 5
                        verticalCenter: parent.verticalCenter
                    }

                    onEditingFinished: _searchRecipe.setIngredientAt(index, text)
                }

                CustomButton {
                    id: removeButton
                    width: 23
                    height: width
                    text: "\u2212"
                    font.pointSize: 15
                    bottomPadding: 10

                    anchors {
                        right: parent.right
                        leftMargin: 10
                    }

                    onClicked: _searchRecipe.removeIngredientAt(index);
                }
            }
        }
    }

    // List recipe
    Frame {
        anchors {
            left: form.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }

        ListView {
            id: listRecipes
            spacing: 5
            clip: true

            anchors {
                fill: parent
                topMargin: 2.5
            }

            ScrollBar.vertical: CustomScrollBar {
                id: recipeScrollBar
            }

            model: _showRecipe

            delegate: MouseArea {
                id: recipe
                width: listRecipes.width - recipeScrollBar.width
                height: 100
                anchors {
                    rightMargin: 5
                }
                Frame { // TEMP
                    anchors.fill:parent
                }

                Text {
                    id: recipeId
                    text: model.recipeId
                    visible: false
                }

                Image {
                    id: recipeImage
                    fillMode: Image.PreserveAspectFit
                    source: {return model.pathImage === "" ? "images/placeholder.png" : model.pathImage}

                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                        margins: 5
                    }
                    Frame { // TEMP
                        anchors.fill:parent
                    }

                    asynchronous : true
                }

                Text {
                    id: recipeTitle
                    text: model.recipeTitle

                    anchors {
                        left: recipeImage.right
                        right: instructions.left
                        top: parent.top
                    }
                    Frame { // TEMP
                        anchors.fill:parent
                    }
                }

                Text{
                    text: "Preparaton time:"
                    anchors {
                        left: recipeImage.right;
                        top: recipeImage.verticalCenter
                    }
                    Frame { // TEMP
                        anchors.fill:parent
                    }
                    Text {
                        id: preparationTime
                        text: model.preparationTime
                        anchors {
                            left: parent.right
                            top: parent.bottom
                        }
                        Frame {  // TEMP
                            anchors.fill:parent
                        }
                    }
                }

                Text {
                    text: "Coooking time:"
                    anchors {
                        left: preparationTime.parent.right
                        top: preparationTime.parent.top
                    }
                    Frame { // TEMP
                        anchors.fill:parent
                    }
                    Text {
                        id: cookingTime
                        text: model.cookingTime
                        anchors {
                            left: parent.right
                            top: parent.bottom
                        }
                        Frame { // TEMP
                            anchors.fill:parent
                        }
                    }
                }

                Text {
                    text: "Yield:"
                    anchors {
                        left: cookingTime.parent.right
                        top: cookingTime.parent.top
                    }
                    Frame { // TEMP
                        anchors.fill:parent
                    }
                    Text {
                        id: yield
                        text: model.yield
                        anchors {
                            left: parent.right
                            top: parent.bottom
                        }
                        Frame { // TEMP
                            anchors.fill:parent
                        }
                    }
                }

                Text {
                    id: instructions
                    text: model.instructions
                    anchors {
                        right: parent.right;
                        top: parent.top
                        bottom: parent.bottom
                    }
                    Frame { // TEMP
                        anchors.fill:parent
                    }
                }
            }
        }
    }
}
