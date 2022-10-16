import qml.imports.Constants
import qml.imports.CustomModules
import Cookbook
import AutocompleteEnum

import QtQuick
import QtQuick.Controls

Item {
    id: root

    readonly property int heightTextField: 23
    readonly property int heightButton: 23

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

    Autocomplete {
        id: title
        role: AutocompleteEnum.Title
        bottomBoundY: root.height
        placeholderText: qsTr("Name recipe")
        height: heightTextField
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

        MouseArea {
            id: mouseArea
            z: -1
            anchors.fill: listView
        }

        model: _searchRecipe

        delegate: Item {
            width: listView.width - scrollBar.width
            height: heightTextField

            anchors {
                rightMargin: 5
            }

            Autocomplete {
                id: ingredient
                role: AutocompleteEnum.Ingredient
                bottomBoundY: listView.height
                width: parent.width/2
                height: heightTextField
                placeholderText: qsTr("Ingredient")
                horizontalAlignment: Text.AlignLeft
                focus: false
                anchors {
                    left: parent.left
                    right: removeButton.left
                    verticalCenter: parent.verticalCenter
                    rightMargin: 5
                }

                onFocusChanged: {
                    if (focus) {
                        var mouseXY = mapToItem(mouseArea, Qt.rect(ingredient.x, ingredient.y, ingredient.width, ingredient.height))
                        componentY = mouseXY.y + ingredient.height
                    }
                }

                onSelected: _searchRecipe.setIngredientAt(index, ingredient.text)

                onEditingFinished: _searchRecipe.setIngredientAt(index, text)
            }

            CustomButton {
                id: removeButton
                width: ingredient.height
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
