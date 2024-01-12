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

    color: Colors.bgPrimary

    CppRecipe {
        id: _recipe

        Component.onCompleted: _recipe.setConnectionName("cookbook")
    }

    Image {
        id: recipeImage

        width: Math.min(parent.width, parent.height) * 0.3
        height: width
        fillMode: Image.PreserveAspectFit
        source: _recipe.pathImage !== "" ? _recipe.pathImage : "icons/placeholder.svg"
        asynchronous : true

        anchors {
            left: parent.left
            top: title.bottom
            leftMargin: Constants.margin
            rightMargin: Constants.margin
            topMargin: Constants.margin
        }

        onStatusChanged: {
            if (recipeImage.status === Image.Error || recipeImage.status === Image.Null) {
                source = "icons/placeholder.svg"
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: { fileDialog.open() }
        }

        // Background image
        Rectangle {
            color: Colors.grey
            anchors.fill: parent
            z:-1
        }
    }

    FileDialog {
        id: fileDialog

        title: "Please choose an image"
        nameFilters: [ "Image files (*.bmp *.jpg *.jpeg *.png *.pbm *.pgm *.ppm *.xpm *.tiff *.svg)" ]

        onAccepted: {
            _recipe.pathImage = fileDialog.currentFile
        }
    }

    CustomTextField {
        id: title

        placeholderText: qsTr("Recipe title")
        height:  35 + 0.03 * parent.height

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: Constants.margin
            rightMargin: Constants.margin
            topMargin: Constants.margin
        }

        onTextChanged: invisibleTitleText.text = text

        onEditingFinished: _recipe.title = text

        Text {
            id: invisibleTitleText

            leftPadding: title.leftPadding
            rightPadding: title.rightPadding
            font.pixelSize: title.height - 8
            fontSizeMode: Text.Fit;
            minimumPixelSize: height / 4
            visible: false

            anchors.fill: title

            onFontInfoChanged: title.font.pixelSize = fontInfo.pixelSize

        }
    }

    Column {
        id: box

        width: 130

        anchors {
            left: recipeImage.right
            top: title.bottom
            bottom: recipeImage.bottom
            margins: Constants.margin
        }

        Label {
            text: qsTr("Preparation time")
            font.pixelSize: preparationTime.font.pixelSize
            color: Colors.text
        }

        CustomTextField {
            id: preparationTime

            placeholderText: qsTr("Preparation time")
            height: 30
            font.pixelSize: 15
            wrapMode: Text.Wrap

            anchors {
                left: parent.left
                right: parent.right
            }

            validator: RegularExpressionValidator { regularExpression: /\d*/ }
            onEditingFinished: _recipe.preparationTime = text ? text : 0
        }

        Label {
            text: qsTr("Cooking time")
            color: Colors.text
        }

        CustomTextField {
            id: cookingTime

            placeholderText: qsTr("Cooking time")
            height: preparationTime.height
            font.pixelSize: preparationTime.font.pixelSize

            anchors {
                left: parent.left
                right: parent.right
            }

            validator: RegularExpressionValidator { regularExpression: /\d*/ }
            onEditingFinished: _recipe.cookingTime = text ? text : 0
        }

        Label {
            text: qsTr("Yield")
            color: Colors.text
        }

        CustomTextField {
            id: yield

            placeholderText: qsTr("Yield")
            height: preparationTime.height
            font.pixelSize: preparationTime.font.pixelSize

            anchors {
                left: parent.left
                right: parent.right
            }

            validator: RegularExpressionValidator { regularExpression: /\d*/ }
            onEditingFinished: _recipe.yield = text ? text : 0
        }
    }
/*
    *************************************************************
*/
    CustomCheckBox {
        id: copyImageCheck

        text: qsTr("Copy image")
        font.pixelSize: 13
        checked: true

        anchors {
            left: parent.left
            top: recipeImage.bottom
            leftMargin: Constants.margin
            rightMargin: Constants.margin
            topMargin: 10
            bottomMargin: 10
        }
    }

    CustomButton {
        id: addIngredientButton

        text: 'Add ingredient'
        height: 20
        font.pixelSize: 13

        anchors {
            left: parent.left
            right: instructions.left
            top: copyImageCheck.bottom
            leftMargin: Constants.margin
            rightMargin: Constants.margin + scrollBar.width
            topMargin: 10
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
                    }

                    onFocusChanged: {
                        if (focus) {
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
                    }

                    onEditingFinished: _recipe.setQuantityAt(index, text)
                }
            }

            CustomButton {
                id: removeButton

                width: 23
                height: width
                text: "\uFF0D"
                font.pixelSize: 15

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

        width: (parent.width + anchors.rightMargin + anchors.leftMargin) / 2
        contentHeight: instructions.height

        anchors {
            left: box.right
            right: parent.right
            top: title.bottom
            bottom: addRecipeButton.top
            margins: Constants.margin
        }

        ScrollBar.vertical: CustomScrollBar {
            anchors {
                right: parent.right
                top: parent.top
                bottom: parent.bottom
            }
        }

        CustomTextArea {
            id: instructionsText

            placeholderText: qsTr("Instructions")

            onEditingFinished: _recipe.instructions = text
        }
    }

    CustomButton {
        id: addRecipeButton

        text: "Add recipe"
        width: parent.width * 0.3
        height: 23
        font.pixelSize: 13

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
                    toolTip_addRecipe.bgColor= Colors.success
                } else {
                    toolTip_addRecipe.text = "Recipe added but unable to copy the image :|"
                    toolTip_addRecipe.bgColor = Colors.warning
                }
            } else {
                toolTip_addRecipe.text = "Failed to add recipe :("
                toolTip_addRecipe.bgColor = Colors.error
            }
            toolTip_addRecipe.open()
        }

        CustomToolTip {
            id: toolTip_addRecipe
        }
    }
}
