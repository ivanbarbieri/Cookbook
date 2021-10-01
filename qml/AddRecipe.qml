import Constants
import CustomModules

import QtQuick
import QtQuick.Controls
import Qt.labs.platform


Rectangle {
    id: root
    color: Colors.darkGrey

    Image {
        id: recipeImage
        width: Math.min(parent.width, parent.height) * 0.3
        height: width
        fillMode: Image.PreserveAspectFit
        source: "images/placeholder.png"

        anchors {
            left: parent.left
            top: parent.top
            margins: Constants.margin
        }

        asynchronous : true

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: { fileDialog.open() }
        }
    }

    FileDialog {
        id: fileDialog
        title: "Please choose an image"
        nameFilters: [ "Image files (*.png *.jpeg *.jpg)" ]

        onAccepted: {
            recipeImage.source = fileDialog.currentFile
        }
    }

    Item {
        id: box1

        anchors {
            left: recipeImage.right
            right: parent.right
            top: recipeImage.top
            bottom: recipeImage.verticalCenter
            leftMargin: Constants.margin
            rightMargin: Constants.margin
        }

        CustomTextField {
            id: recipeTitle
            placeholderText: qsTr("Recipe title")
            height:  35 + 0.3 * parent.height
            font.pixelSize: 15 + height * 0.05

            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
        }
    }

    Item {
        id: box2

        anchors {
            left: recipeImage.right
            right: parent.right
            top: recipeImage.verticalCenter
            bottom: recipeImage.bottom
            leftMargin: Constants.margin
            rightMargin: Constants.margin
        }

        CustomTextField {
            id: preparationTime
            placeholderText: qsTr("Preparation time")
            width: recipeTitle.width * 0.3
            height: 35 + 0.15 * parent.height
            font.pixelSize: 15 + height * 0.05
            wrapMode: Text.Wrap

            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
        }

        CustomTextField {
            id: cookingTime
            placeholderText: qsTr("Cooking time")
            width: (recipeTitle.width * 0.3)
            height: preparationTime.height
            font.pixelSize: 15 + height * 0.05

            anchors {
                left: preparationTime.right
                leftMargin: Constants.margin
                verticalCenter: parent.verticalCenter
            }
        }

        CustomTextField {
            id: yield
            placeholderText: qsTr("Yield")
            width: (recipeTitle.width * 0.3)
            height: preparationTime.height
            font.pixelSize: 15 + height * 0.05


            anchors {
                left: cookingTime.right
                right: parent.right
                leftMargin: Constants.margin
                verticalCenter: parent.verticalCenter
            }

        }
    }
/*
    *************************************************************
*/
    CustomButton {
        id: addIngredientButton
        text: 'Add ingredient'
        height: 16

        anchors {
            left: parent.left
            right: instruction.left
            top: recipeImage.bottom
            leftMargin: Constants.margin
            rightMargin: Constants.margin + scrollBar.width
            topMargin: Constants.margin
            bottomMargin: 2.5
        }

        onClicked: _addRecipe.appendIngredient()
    }

    ListView {
        id: listView
        spacing: 5
        clip: true

        anchors {
            left: parent.left
            right: instruction.left
            top: addIngredientButton.bottom
            bottom: addRecipeButton.top
            leftMargin: Constants.margin
            rightMargin: Constants.margin
            topMargin: 2.5
            bottomMargin: Constants.margin

        }

        ScrollBar.vertical: CustomScrollBar {
            id: scrollBar
        }

        model: _addRecipe

        delegate: Item {
            anchors.rightMargin: 5
            width: listView.width - scrollBar.width
            height: Math.max(ingredient.height, quantity.height)

            Item {
                id: ingredientForm

                anchors {
                  left: parent.left
                  right: removeButton.left
                  top:  parent.top
                  bottom: parent.bottom
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
                        rightMargin: 5
                        verticalCenter: parent.verticalCenter
                    }

//                    text: _addRecipe.name
                    onEditingFinished: _addRecipe.setNameAt(index, text)
                }

                CustomTextField {
                    id: quantity
                    placeholderText: qsTr("Quantity")
                    width: ingredient.width
                    height: 23 * text.lineCount
                    horizontalAlignment: Text.AlignLeft

                    anchors {
                        left: ingredient.right
                        right: parent.right
                        leftMargin: 5
                        verticalCenter: parent.verticalCenter
                    }

//                    text: _addRecipe.quantity
                    onEditingFinished: _addRecipe.setQuantityAt(index, text)
                }
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
                    verticalCenter: parent.verticalCenter
                }

                onClicked: _addRecipe.removeIngredientAt(index);
            }
        }
    }

    CustomButton {
        id: addRecipeButton
        text: "Add recipe"
        width: parent.width * 0.3
        height: 20
        font.pointSize: 15

        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: Constants.margin
        }

        onClicked: _addRecipe.addRecipe(recipeImage.source.toString(),
                                          recipeTitle.text.toString(),
                                          preparationTime.text.toString(),
                                          cookingTime.text.toString(),
                                          yield.text.toString(),
                                          instructionText.text.toString())
    }

    ScrollView {
        id: instruction
        width: (parent.width + anchors.rightMargin + anchors.leftMargin)/2
        clip: true

        anchors {
            right: parent.right
            top: recipeImage.bottom
            bottom: addRecipeButton.top
            topMargin: Constants.margin
            rightMargin: Constants.margin
            bottomMargin: Constants.margin
        }

        TextArea {
            id: instructionText
            placeholderText: qsTr("Instructions")
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
