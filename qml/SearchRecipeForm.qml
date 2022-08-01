import qml.imports.Constants
import qml.imports.CustomModules
import Cookbook

import QtQuick
import QtQuick.Controls

Item {
    id: root

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

        onClicked: _searchRecipe.search(title.text)
    }

    CustomTextField {
        id: title
        placeholderText: qsTr("Name recipe")
        horizontalAlignment: Text.AlignLeft

        color: Colors.white
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
            top: title.bottom
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
//                id: ingredientForm
            width: listView.width - scrollBar.width
            height: 23 //ingredient.height

            anchors {
                rightMargin: 5
            }

            CustomTextField {
                id: ingredient
                placeholderText: qsTr("Ingredient")
                width: parent.width/2
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
