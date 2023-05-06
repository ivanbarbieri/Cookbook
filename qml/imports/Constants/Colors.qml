pragma Singleton
import QtQuick

QtObject {
    readonly property color bgPrimary: darkGrey
    readonly property color bgSecondary: darkerGray

    readonly property color bgText: grey
    readonly property color text: white
    readonly property color selection: darkGrey
    readonly property color selectedText: white
    readonly property color placeholderText: lightGrey

    readonly property color textTab: text
    readonly property color selectedTab: grey
    readonly property color unselectedTab: bgSecondary

    readonly property color success: green
    readonly property color warning: orange
    readonly property color error: red



    readonly property color darkerGray: "#121317"
    readonly property color darkGrey: "#23252F"
    readonly property color grey: "#36394A"
    readonly property color lightGrey: "#A3A3A3"
 
    readonly property color transparent: "#00000000"
    readonly property color black: "black"
    readonly property color white: "white"
    readonly property color red: "red"
    readonly property color orange: "orange"
    readonly property color green: "green"
}
