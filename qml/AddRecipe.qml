import qml.imports.Constants
import qml.imports.CustomModules
import Cookbook
import AutocompleteEnum

import QtQuick
import QtQuick.Controls
import Qt.labs.platform
import QtQuick.Dialogs

Rectangle {
    id: root

    color: Colors.darkGrey

    CppRecipe {
        id: _recipe

        Component.onCompleted: _recipe.setConnectionName("cookbook")
    }

    Image {
        id: recipeImage

        width: Math.min(parent.width, parent.height) * 0.3
        height: width
        fillMode: Image.PreserveAspectFit
        source: _recipe.pathImage  !== "" ? _recipe.pathImage : "icons/placeholder.svg"

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
        nameFilters: [ "Image files (*.bmp *.jpg *.jpeg *.png *.pbm *.pgm *.ppm *.xpm *.tiff *.svg)" ]

        onAccepted: {
            _recipe.pathImage = fileDialog.currentFile
            console.log(_recipe.pathImage)
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
            id: title
            placeholderText: qsTr("Recipe title")
            height:  35 + 0.3 * parent.height
            font.pixelSize: 15 + height * 0.05

            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            onEditingFinished: _recipe.title = text
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
            width: title.width * 0.3
            height: 35 + 0.15 * parent.height
            font.pixelSize: 13 + height * 0.05
            wrapMode: Text.Wrap

            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }

            validator: RegularExpressionValidator { regularExpression: /\d*/ }
            onEditingFinished: _recipe.preparationTime = text ? text : 0
        }

        CustomTextField {
            id: cookingTime

            placeholderText: qsTr("Cooking time")
            width: title.width * 0.3
            height: preparationTime.height
            font.pixelSize: 13 + height * 0.05

            anchors {
                left: preparationTime.right
                leftMargin: Constants.margin
                verticalCenter: parent.verticalCenter
            }

            validator: RegularExpressionValidator { regularExpression: /\d*/ }
            onEditingFinished: _recipe.cookingTime = text ? text : 0
        }

        CustomTextField {
            id: yield

            placeholderText: qsTr("Yield")
            width: title.width * 0.3
            height: preparationTime.height
            font.pixelSize: 13 + height * 0.05

            anchors {
                left: cookingTime.right
                right: parent.right
                leftMargin: Constants.margin
                verticalCenter: parent.verticalCenter
            }

            validator: RegularExpressionValidator { regularExpression: /\d*/ }
            onEditingFinished: _recipe.yield = text ? text : 0
        }
    }
/*
    *************************************************************
*/

    Item {
        id: copyImageCheckBox

        anchors {
            left: parent.left
            top: recipeImage.bottom
            bottom: addIngredientButton.top
            leftMargin: Constants.margin
            rightMargin: Constants.margin
        }

        CheckBox {
            id: copyImageCheck

            text: qsTr("Copy image")
            height: 20
            width: 100
            font.pixelSize: 15
            checked: true

            anchors.verticalCenter: copyImageCheckBox.verticalCenter

            contentItem: Text {
                text: copyImageCheck.text
                color: Colors.white
                verticalAlignment: Text.AlignVCenter
                leftPadding: copyImageCheck.indicator.width + copyImageCheck.spacing
            }

            MouseArea {
                anchors.fill: copyImageCheck
                cursorShape: Qt.PointingHandCursor
                onClicked: {copyImageCheck.checked = !copyImageCheck.checked}
            }
        }
    }

    CustomButton {
        id: addIngredientButton

        text: 'Add ingredient'
        height: 20

        anchors {
            left: parent.left
            right: instructions.left
            top: instructions.top
            leftMargin: Constants.margin
            rightMargin: Constants.margin + scrollBar.width
            bottomMargin: 2.5
        }

        onClicked: _recipe.appendIngredient()
    }

    ListView {
        id: listView
        spacing: 5
        clip: true

        anchors {
            left: parent.left
            right: instructions.left
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

        MouseArea {
            id: mouseArea
            z: -1
            anchors.fill: listView
        }

        model: _recipe

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

                Autocomplete {
                    id: ingredient
                    role: AutocompleteEnum.Ingredient
                    bottomBoundY: listView.height
                    componentY: 0
                    placeholderText: qsTr("Ingredient")
                    width: ingredientForm.width / 2
                    horizontalAlignment: Text.AlignLeft

                    anchors {
                        left: parent.left
                        rightMargin: 5
                        verticalCenter: parent.verticalCenter
                    }

                    onFocusChanged: {
                        if (focus) {
                            console.log("index " + index)
                            var mouseXY = mapToItem(mouseArea, Qt.rect(ingredient.x, ingredient.y, ingredient.width, ingredient.height))
                            componentY = mouseXY.y + ingredient.height
                        }
                    }

                    onEditingFinished: _recipe.setNameAt(index, text)
                }

                CustomTextField {
                    id: quantity
                    placeholderText: qsTr("Quantity")
                    width: ingredientForm.width / 2
                    horizontalAlignment: Text.AlignLeft

                    anchors {
                        left: ingredient.right
                        right: parent.right
                        leftMargin: 5
                        verticalCenter: parent.verticalCenter
                    }

                    onEditingFinished: _recipe.setQuantityAt(index, text)
                }
            }

            CustomButton {
                id: removeButton
                width: 23
                height: width
                text: "\u2212"
                font.pixelSize: 15
                bottomPadding: 10

                anchors {
                    right: parent.right
                    leftMargin: 10
                    verticalCenter: parent.verticalCenter
                }

                onClicked: _recipe.removeIngredientAt(index);
            }
        }
    }

    ScrollView {
        id: instructions
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
            id: instructionsText
            placeholderText: qsTr("Instructions")
            selectionColor: Colors.darkGrey
            selectedTextColor: Colors.white
            wrapMode: Text.Wrap
            font.pixelSize: 15
            background: Rectangle {
                color: Colors.grey
                radius: Constants.radius
            }

            onEditingFinished: _recipe.instructions = text
        }
    }

    CustomButton {
        id: addRecipeButton
        text: "Add recipe"
        width: parent.width * 0.3
        height: 20
        font.pixelSize: 15

        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: Constants.margin
        }

        onClicked: {
            if (_recipe.addRecipe()) {
                let copied = false
                if (copyImageCheck.checked)
                    copied = _recipe.copyImage()

                if (copyImageCheck.checked === copied) {
                    toolTip_addRecipe.text = "Recipe added :)"
                    toolTip_addRecipe.bgColor= Colors.green
                } else {
                    toolTip_addRecipe.text = "Recipe added but unable to copy the image :|"
                    toolTip_addRecipe.bgColor = Colors.orange
                }
            } else {
                toolTip_addRecipe.text = "Failed to add recipe :("
                toolTip_addRecipe.bgColor = Colors.red
            }
            toolTip_addRecipe.open()
        }

        CustomToolTip {
            id: toolTip_addRecipe
        }
    }
}
