import Constants

import QtQuick
import QtQuick.Controls

Frame {
    width: parent.width
    height: parent.height
    padding: 0

    Rectangle {
        id: forms
        width: 150
        height: parent.height
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.top: parent.top
        color: Colors.darkGrey

        Button {
            id: searchButton
            text: 'Search'
            width: parent.width
            height: 20
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.right: parent.right
        }

        ListView {
            id: listView
            width: parent.width
            anchors.top: searchButton.bottom
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            clip: true
            model: ListModel { id: listModel }
            delegate: numberForm
            footer: footerListForms
        }

        Component {
            id: numberForm;

            Rectangle {
                width: 150
                height: 30
                anchors.left: parent.left
                color: Colors.black

                Rectangle {
                    color: Colors.darkGrey
                    anchors.right: searchButton.left
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.rightMargin: 5
                    anchors.leftMargin: 5
                    anchors.bottomMargin: 5
                    anchors.topMargin: 5

                    TextInput {
                        text: qsTr("Ingredient")
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignLeft
                        font.pointSize: 12
                        color: Colors.white
                        selectionColor: Colors.lightGrey
                    }
                }

                Button {
                    id: searchButton
                    width: 20
                    height: 20
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.top: parent.top
                    anchors.rightMargin: 5
                    anchors.leftMargin: 5
                    anchors.bottomMargin: 5
                    anchors.topMargin: 5
                    text: "\u2212"
                    spacing: 5
                    font.pointSize: 15
                    onClicked: listModel.remove(index);
                }
            }

        }

        Component {
            id: footerListForms

            Button {
                text: 'Add Form'
                height: 20
                anchors.centerIn: parent
                onClicked: listModel.append({})
            }
        }
    }
}
