import qml.imports.Constants
import qml.imports.CustomModules
import Cookbook
import AutocompleteEnum

import QtQuick
import QtQuick.Controls

Item {
    id: root

    CustomButton {
        id: searchButton

        text: 'Search'
        width: parent.width
        height: Constants.height

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottomMargin: 10
        }

        onClicked: _searchRecipe.search(title.text)
    }

    Autocomplete {
        id: title

        role: AutocompleteEnum.Title
        bottomBoundY: root.height
        placeholderText: qsTr("Name recipe")
        height: Constants.height

        anchors {
            left: parent.left
            right: parent.right
            top: searchButton.bottom
            topMargin: 10
            bottomMargin: 10
        }
    }

    CustomButton {
        id: addIngredientButton

        text: 'Add ingredient'
        height: Constants.height

        anchors {
            left: parent.left
            right: parent.right
            top: title.bottom
            topMargin: 10
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

            enabled: scrollBar.opacity
            hoverEnabled: scrollBar.opacity
        }

        MouseArea {
            id: mouseArea
            z: -1
            anchors.fill: listView
        }

        model: _searchRecipe

        delegate: Item {
            width: listView.width - (scrollBar.opacity ? scrollBar.width : 0)
            height: Constants.height

            anchors {
                rightMargin: 5
            }

            Autocomplete {
                id: ingredient

                role: AutocompleteEnum.Ingredient
                bottomBoundY: listView.height
                width: parent.width / 2
                height: Constants.height
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
                text: '\uFF0D'
                font.pixelSize: Constants.pixelSize

                anchors {
                    right: parent.right
                    leftMargin: 10
                }

                onClicked: _searchRecipe.removeIngredientAt(index);
            }
        }
    }
}
