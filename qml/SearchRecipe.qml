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
            spacing: 10
            clip: true

            anchors {
                fill: parent
                topMargin: 2.5
            }

            ScrollBar.vertical: CustomScrollBar {
                id: recipeScrollBar
            }

            model: _showRecipe

            delegate: Frame {
                id: recipe
                height: 100
                width: listRecipes.width - recipeScrollBar.width

                Item {
                    id: content
                    state: "docked"
                    anchors {
                        fill: parent
                    }

                    ToolBar {
                        id: toolBar
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                        }
                        Text {
                            id: recipeTitle
                            text: model.recipeTitle
                            font.pointSize: 24

                            anchors {
                                left: parent.left
                                right: dragMouseArea.left
                                verticalCenter: parent.verticalCenter
                                leftMargin: 2.5
                            }
                        }

                        MouseArea {
                            property var clickPos

                            id: dragMouseArea
                            anchors.fill: parent
                            onPressed: {
                                clickPos = Qt.point(mouseX,mouseY)
                            }
                            onPositionChanged: {
                                var delta = Qt.point(mouseX - clickPos.x, mouseY - clickPos.y)
                                var new_x = window.x + delta.x
                                var new_y = window.y + delta.y
                                window.x = new_x
                                window.y = new_y
                            }
                        }
                        Row {
                            anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 8 }
                            Button {
                                flat: true
                                icon.source: content.state == "docked" ?
                                                 "qrc:images/placeholder.png" : "qrc:images/placeholder.png"
                                onClicked: {
                                    if(content.state == "docked")
                                        content.state = "undocked"
                                    else
                                        content.state = "docked"
                                }
                            }
                        }
                    }

                    Text {
                        id: recipeId
                        text: model.recipeId
                        visible: false
                    }

                    Image {
                        id: recipeImage
                        height: recipe.height
                        fillMode: Image.PreserveAspectFit
                        source: {return model.pathImage === "" ? "images/placeholder.png" : model.pathImage}

                        anchors {
                            left: parent.left
                            top: toolBar.bottom
                            bottom: parent.bottom
                            margins: 2.5
                        }

                        asynchronous : true
                    }

                    Column {
                        id: box
                        anchors {
                            left: recipeImage.right
                            top: recipeImage.top
                            bottom: recipeImage.bottom
                            rightMargin: Constants.margin

                        }
                        Row {
                            Text {
                                text: qsTr("Preparaton time ")
                            }
                            Text {
                                id: preparationTime
                                text: model.preparationTime
                                wrapMode: Text.Wrap
                            }

                        }
                        Row {
                            Text {
                                text: qsTr("Coooking time ")
                            }
                            Text {
                                id: cookingTime
                                text: model.cookingTime
                                wrapMode: Text.Wrap
                            }
                        }
                        Row {
                            Text {
                                text: qsTr("Yield ")
                            }
                            Text {
                                id: yield
                                text: model.yield
                                wrapMode: Text.Wrap
                            }
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
                            leftMargin: Constants.margin
                        }
                        ScrollBar.vertical: CustomScrollBar {
                            anchors.top: scrollInstruction.top
                            anchors.right: scrollInstruction.right
                            anchors.bottom: scrollInstruction.bottom
                        }

                        TextArea {
                            id: instructions
                            text: model.instructions
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

                    /*
                    CustomTextField {
                        id: instructions
                        text: model.instructions
                        readOnly: true
                        anchors {
                            left: box.right
                            right: parent.right;
                            top: toolBar.bottom
                            bottom: parent.bottom
                            margins: 2.5
                        }
                    }
*/
                    states: [
                        State {
                            name: "undocked"
                            PropertyChanges { target: recipe; height: 0 }
                            PropertyChanges { target: window; visible: true }
                            PropertyChanges { target: recipeImage; height: Math.min(parent.width, parent.height) * 0.3; anchors.bottom: undefined}

                            ParentChange { target: content; parent: undockedContainer }
                        },
                        State {
                            name: "docked"
                            PropertyChanges { target: recipe; height: 100 }
                            PropertyChanges { target: window; visible: false }
                            PropertyChanges { target: recipeImage; height: recipe.height; anchors.bottom: parent.bottom}
                            ParentChange { target: content; parent: recipe }
                        }
                    ]
                }

                Window {
                    id: window
                    color: Colors.darkGrey
                    width: Constants.minWidth
                    height: Constants.minHeight
                    minimumWidth: Constants.minWidth
                    minimumHeight: Constants.minHeight

                    flags: Qt.Window
                    Item {
                        id: undockedContainer
                        anchors.fill: parent
                    }

                    onClosing: {
                        content.state = "docked"
                    }
                }
            }
        }
    }
}
