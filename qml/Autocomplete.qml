import qml.imports.Constants
import qml.imports.CustomModules
import Cookbook

import QtQuick
import QtQuick.Controls

CustomTextField {
    id: root

    // this signal is emitted when a word is selected
    signal selected

    readonly property int suggestionHeight: Constants.height
    // the maximum number of items in the suggestion list
    readonly property int maxItem: 5
    // init with an AutocompleteEnum to choose the type of suggestion
    property int role
    // the bottom bound of the parent
    property int bottomBoundY: 0
    // the y coordinate of this component in the parent
    property int componentY: 0
    // check if listview needs to be rotated to fit inside the parent
    property bool isRotated: bottomBoundY < componentY + (suggestionHeight * maxItem)

    implicitWidth: parent.width
    horizontalAlignment: Text.AlignLeft
    focus: true

    onSelected: root.forceActiveFocus()

    onTextEdited: {
        _autocomplete.suggestions(role, text)
    }

    Keys.onPressed: (event) => {
        // CTRL + SPACE
        if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_Space) {
            _autocomplete.suggestions(role, text)
            root.focus = true
            popup.open()
            suggestionList.visible = true
            suggestionList.currentIndex = 0
            event.accepted = true
        } else if (suggestionList.visible && (
                       event.key === Qt.Key_Tab ||
                       event.key === Qt.Key_Up ||
                       event.key === Qt.Key_Down)) {
            suggestionList.currentIndex = 0
            popup.forceActiveFocus()
            event.accepted = true
        }
    }

    Popup {
        id: popup

        x: parent.x
        padding: 0
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        onOpened: {
            if (suggestionList.count <= 0)
                popup.close()
        }

        ListView {
            id: suggestionList

            width: root.width
            height: suggestionHeight * maxItem
            clip: true
            focus: true
            rotation: isRotated ? 180 : 0

            ScrollBar.vertical: CustomScrollBar {
                id: scrollBar
            }

            Keys.onPressed: (event) => {
                switch (event.key) {
                    case Qt.Key_Escape:
                        root.focus = true
                        suggestionList.visible = false
                        popup.close()
                        event.accepted = true;
                    break
                    case Qt.Key_Enter: // Enter(Numericpad)
                    case Qt.Key_Return:  // Enter
                        root.text = _autocomplete.suggestionAt(suggestionList.currentIndex)                        
                        selected()
                        popup.close()
                        suggestionList.visible = false
                        root.focus = true
                        event.accepted = true
                    break
                    case Qt.Key_Up:
                        if (isRotated) {
                            suggestionList.currentIndex++
                        } else {
                            suggestionList.currentIndex--
                        }

                        if (suggestionList.currentIndex < 0) {
                            suggestionList.currentIndex = suggestionList.count - 1
                        } else if (suggestionList.currentIndex >= suggestionList.count) {
                            suggestionList.currentIndex = 0
                        }
                        event.accepted = true
                    break
                    case Qt.Key_Down:
                        if (isRotated) {
                            suggestionList.currentIndex--
                        } else {
                            suggestionList.currentIndex++
                        }

                        if (suggestionList.currentIndex < 0) {
                            suggestionList.currentIndex = suggestionList.count - 1
                        } else if (suggestionList.currentIndex >= suggestionList.count){
                            suggestionList.currentIndex = 0
                        }
                        event.accepted = true
                    break
                    default:
                    break
                }
            }

            model: _autocomplete

            delegate: CustomButton {
                id: suggestion

                width: suggestionList.width - (suggestionList.count > maxItem ? scrollBar.width : 0)
                height: suggestionHeight
                text: _autocomplete.suggestionAt(model.index)
                rotation: isRotated ? 180 : 0
                radius: 0

                background: Rectangle {
                    id: bg

                    color: index === suggestionList.currentIndex ? Colors.lightGrey : Colors.white

                    border.width: index === suggestionList.currentIndex ? 2 : 0
                    border.color: suggestion.down ? Colors.white : index === suggestionList.currentIndex ? Colors.bgSecondary : Colors.lightGrey
                    radius: 0

                    MouseArea {
                        id: bgArea
                        hoverEnabled: true
                        z: -1

                        anchors.fill: bg

                        onMouseXChanged: {
                            suggestionList.currentIndex = index
                        }

                        onMouseYChanged: {
                            suggestionList.currentIndex = index
                        }

                        onEntered: {
                            suggestionList.currentIndex = index
                        }
                    }
                }

                KeyNavigation.tab: root

                onClicked: {
                    root.text = text
                    selected()
                    suggestionList.visible = false
                }

                Component.onCompleted: {
                    if (isRotated) {
                        if (suggestionList.count >= maxItem) {
                            suggestionList.height = suggestionHeight * maxItem
                        } else {
                            suggestionList.height = suggestionHeight * suggestionList.count
                        }
                        popup.y = root.y - suggestionList.height
                    } else {
                        popup.y = root.y + root.height
                    }
                }
            }
        }
    }
}
