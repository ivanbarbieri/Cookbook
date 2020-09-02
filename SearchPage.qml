import QtQuick 2.9
import QtQuick.Controls 2.2

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
        color: "#26282a"

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
                color: "#000000"

                Rectangle {
                    color: "#26282a"
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
                        color: "#ffffff"
                        selectionColor: "#2828ff"
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
