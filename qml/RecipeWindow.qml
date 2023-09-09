import qml.imports.Constants
import qml.imports.CustomModules
import Cookbook
import AutocompleteEnum

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.platform
import QtQuick.Dialogs

Window {
    id: root
    color: Colors.bgPrimary
    width: Constants.minWidth
    height: Constants.minHeight
    minimumWidth: Constants.minWidth
    minimumHeight: Constants.minHeight
    visible: false

    MouseArea {
        id: mouseAreaAutocomplete

        z: -1
        anchors.fill: parent
    }

    ListView {
        id: tabBar

        currentIndex: 0
        property int prevIndex: 0

        height: 25 + tabBarScrollbar.height
        orientation: ListView.Horizontal
        spacing: 3
        clip: true
        focus: true

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        addDisplaced: Transition {
            NumberAnimation { properties: "x,y"; duration: 1000 }
        }

        ScrollBar.horizontal: CustomScrollBar {
            id: tabBarScrollbar
            orientation: Qt.Horizontal
            interactive: true
        }

        model: _selectedRecipes

        delegate: CustomButton {
            id: tab

            property alias tabButton: removeTab
            property alias tabText: tabLabel

            height: 25
            width: 100
            bgColor: tabBar.currentIndex === index ? Colors.selectedTab : Colors.unselectedTab
            radius: 0

            onClicked: {
                if (tabBar.prevIndex >= 0 && tabBar.currentIndex !== index) {
                    tabBar.prevIndex = index
                }

                focus = true
                tabBar.currentIndex = index
            }

            onHoveredChanged: {
                if (hovered === true) {
                    tabLabel.color = Colors.textTab
                } else {
                    if (tabBar.currentIndex !== index) {
                        tabLabel.color = Colors.lightGrey
                    }
                }
            }

            onFocusChanged: {
                if (focus === true) {
                    tab.bgColor = Colors.selectedTab
                    tabLabel.color = Colors.textTab
                    listview.positionViewAtIndex(index, ListView.Contain)
                } else {
                    tab.bgColor = Colors.unselectedTab
                    tabLabel.color = Colors.lightGrey
                }
            }

            contentItem: Text {
                id: tabLabel

                height: parent.height
                width: parent.width * 0.75
                text: _selectedRecipes.recipe(index).title ?? ""
                color: hovered || tabBar.currentIndex === index ? Colors.white : Colors.lightGrey
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter

                anchors {
                    left: parent.left
                    right: removeTab.left
                    top: parent.top
                    bottom: parent.bottom
                    margins: 5
                }
            }

            CustomButton {
                id: removeTab

                width: height
                text: '\u2715'
                padding: 0
                bgColor: Colors.transparent
                bgBorderWidth: 0
                labelColor: hovered || tabBar.currentIndex === index ? Colors.white : Colors.lightGrey
                font.bold: true
                font.pixelSize: Constants.pixelSize
                focusPolicy: Qt.NoFocus

                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    margins: 5
                }

                onClicked: {
                    _selectedRecipes.removeRecipe(index)
                    if (listview.count <= 0)
                        root.visible = false

                    if (tabBar.prevIndex >= listview.count)
                        tabBar.prevIndex = 0
                }
            }

            ListView.onAdd: {
                if (tabBar.prevIndex >= 0) {
                    tabBar.itemAtIndex(tabBar.prevIndex).bgColor = Colors.unselectedTab
                    tabBar.itemAtIndex(tabBar.prevIndex).tabText.color = Colors.lightGrey
                    tabBar.prevIndex = index
                }

                tabBar.currentIndex = tabBar.count - 1
                listview.positionViewAtIndex(tabBar.currentIndex, ListView.Contain)
            }
        }
    }

    ListView {
        id: listview

        clip: true
        interactive: false
        snapMode: ListView.SnapToItem

        anchors {
            left: parent.left
            right: parent.right
            top: tabBar.bottom
            bottom: parent.bottom
        }

        model: _selectedRecipes
        delegate: Item {
            id: recipe

            property bool editable: false
            property int parentIndex: index

            property var p_recipe: _selectedRecipes.recipe(index)
            property string p_title: p_recipe?.title ?? ""
            property string p_pathImage: p_recipe?.pathImage ? p_recipe.pathImage : "icons/placeholder.svg"
            property int p_preparationTime: p_recipe?.preparationTime ?? 0
            property int p_cookingTime: p_recipe?.cookingTime ?? 0
            property int p_yield: p_recipe?.yield ?? 0
            property string p_instructions: p_recipe?.instructions ?? ""

            implicitHeight: listview.height
            implicitWidth: listview.width

            CustomTextField {
                id: title

                placeholderText: qsTr("Title")
                text: recipe.p_title
                implicitWidth: listview.width
                height:  35 + 0.03 * parent.height
                readOnly: {!editable}
                cursorShape: editable ? Qt.IBeamCursor : Qt.ArrowCursor
                leftPadding: invisibleTitleText.leftPadding
                rightPadding: invisibleTitleText.rightPadding

                anchors {
                    left: recipe.left
                    right: recipe.right
                    top: parent.top
                    margins: Constants.margin
                }

                onTextChanged: invisibleTitleText.text = text

                Text {
                    id: invisibleTitleText

                    font.pixelSize: title.height - 8
                    fontSizeMode: Text.Fit;
                    minimumPixelSize: height / 3
                    visible: false
                    leftPadding: 10
                    rightPadding: 10

                    anchors.fill: title

                    onFontInfoChanged: title.font.pixelSize = fontInfo.pixelSize
                }
            }

            Image {
                id: recipeImage

                property bool imageChanged: false

                width: Math.min(listview.width, listview.height) * 0.3
                height: width
                fillMode: Image.PreserveAspectFit
                source: recipe.p_pathImage
                asynchronous : true

                anchors {
                    left: parent.left
                    top: title.bottom
                    margins: Constants.margin
                }

                onStatusChanged: {
                    if (recipeImage.status === Image.Error || recipeImage.status === Image.Null) {
                        source = "icons/placeholder.svg"
                    }

                    if (recipe.p_pathImage != recipeImage.source) {
//                        recipeImage.source = recipe.p_pathImage
                        imageChanged = true
                        copyImageCheckBox.checked = true
                    } else {
                        imageChanged = false
                        copyImageCheckBox.checked = false
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: editable ? Qt.PointingHandCursor : Qt.ArrowCursor

                    enabled: editable
                    onClicked: { fileDialog.open() }
                }

                FileDialog {
                    id: fileDialog

                    title: "Please choose an image"
                    nameFilters: [ "Image files (*.bmp *.jpg *.jpeg *.png *.pbm *.pgm *.ppm *.xpm *.tiff *.svg)" ]

                    onAccepted: {
                        recipeImage.source = fileDialog.currentFile
                    }
                }

                // Background image
                Rectangle {
                    color: Colors.grey
                    anchors.fill: parent
                    z:-1
                }
            }

            Column {
                id: box

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

                    text: recipe.p_preparationTime
                    height: Constants.height
                    font.pixelSize: Constants.pixelSize
                    validator: RegularExpressionValidator { regularExpression: /\d*/ }
                    readOnly: {!editable}
                    cursorShape: editable ? Qt.IBeamCursor : Qt.ArrowCursor
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                }

                Label {
                    text: qsTr("Cooking time")
                    font.pixelSize: preparationTime.font.pixelSize
                    color: Colors.text
                }

                CustomTextField {
                    id: cookingTime

                    text: recipe.p_cookingTime
                    height: preparationTime.height
                    font.pixelSize: preparationTime.font.pixelSize
                    validator: RegularExpressionValidator { regularExpression: /\d*/ }
                    readOnly: {!editable}
                    cursorShape: editable ? Qt.IBeamCursor : Qt.ArrowCursor
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                }

                Label {
                    text: qsTr("Yield")
                    font.pixelSize: preparationTime.font.pixelSize
                    color: Colors.text
                }

                RowLayout {
                    id: yieldButtons

                    signal yieldButtonClicked(str: string, oldYield: int, newYield: int)

                    spacing: 5

                    anchors {
                        left: parent.left
                        right:parent.right
                    }

                    CustomButton {
                        id: minusYieldButton

                        text: '\uFF0D'
                        Layout.preferredHeight: yield.height
                        Layout.preferredWidth: height
                        font.pixelSize: yield.font.pixelSize
                        visible: !editable

                        onClicked: {
                            yield.text = Number(yield.text) > 0 ? Number(yield.text) - 1 : 0
                        }
                    }

                    CustomTextField {
                        id: yield

                        text: recipe.p_yield
                        Layout.preferredHeight: preparationTime.height
                        font.pixelSize: preparationTime.font.pixelSize
                        validator: RegularExpressionValidator { regularExpression: /\d*/ }
                        readOnly: !editable
                        cursorShape: editable ? Qt.IBeamCursor : Qt.ArrowCursor

                        Layout.fillWidth: parent
                    }

                    CustomButton {
                        id: plusYieldButton
                        text: '\uFF0B'
                        Layout.preferredHeight: yield.height
                        Layout.preferredWidth: height
                        font.pixelSize: yield.font.pixelSize
                        visible: !editable

                        onClicked: {
                            yield.text = Number(yield.text) + 1
                        }
                    }
                }
            }

            Row {
                id: imageCheckBox

                height: visible ? Constants.height : 0
                spacing: 5
                visible: editable && recipeImage.imageChanged

                anchors {
                    left: parent.left
                    top: recipeImage.bottom
                    leftMargin: Constants.margin
                    rightMargin: Constants.margin
                    topMargin: 10
                    bottomMargin: 10
                }

                CustomCheckBox {
                    id: copyImageCheckBox

                    text: qsTr("Copy image")
                    height: imageCheckBox.height
                    font.pixelSize: Constants.pixelSize
                    enabled: editable
                    checked: false
                }

                CustomCheckBox {
                    id: deleteImageCheckBox

                    text: qsTr("Delete previous image")
                    height: imageCheckBox.height
                    font.pixelSize: copyImageCheckBox.font.pixelSize
                    enabled: editable
                    checked: false
                }
            }

            ScrollView {
                id: scrollInstruction

                implicitHeight: parent.height
                implicitWidth: parent.width

                clip: true

                anchors {
                    leftMargin: Constants.margin
                    rightMargin: Constants.margin
                    bottomMargin: Constants.margin
                }

                ScrollBar.vertical: CustomScrollBar {
                    id: instructionsScrollBar

                    anchors {
                        right: scrollInstruction.right
                        top: scrollInstruction.top
                        bottom: scrollInstruction.bottom
                    }
                }

                CustomTextArea {
                    id: instructionsText

                    placeholderText: qsTr("Instructions")
                    text: p_instructions
                    readOnly: {!editable}
                    MouseArea {
                        hoverEnabled: true
                        cursorShape: editable ? Qt.IBeamCursor : Qt.ArrowCursor
                        anchors.fill: parent

                        onClicked: instructionsText.forceActiveFocus()
                    }
                }
            }

            Item {
                id: ingredientBox

                anchors {
                    left: parent.horizontalCenter
                    right: parent.right
                    top: title.bottom
                    bottom: scrollInstruction.top
                    leftMargin: Constants.margin
                    rightMargin: Constants.margin
                    topMargin: 5
                    bottomMargin: Constants.margin
                }

                CustomButton {
                    id: addIngredientButton

                    text: 'Add ingredient'
                    height: editable ? Constants.height : 0
                    font.pixelSize: Constants.pixelSize
                    enabled: editable
                    visible: editable
                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                   onClicked: recipe.p_recipe.appendIngredient()
                }

                ListView {
                    id: ingredientsList

                    property int parentIndex: index

                    spacing: 5
                    clip: true
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: addIngredientButton.bottom
                        bottom: parent.bottom
                    }

                    ScrollBar.vertical: CustomScrollBar {
                        id: ingredientsListScrollBar
                    }

                    model: recipe.p_recipe

                    delegate: Item {
                        id: ingredient

                        property string p_name: recipe.p_recipe?.name(index) ?? ""
                        property string p_quantity: recipe.p_recipe?.quantity(index) ?? ""

                        width: ingredientsList.width - (ingredientsListScrollBar.opacity ? ingredientsListScrollBar.width : 0)
                        height: Math.max(name.height, quantity.height)
                        anchors.rightMargin: 5


                        Item {
                            id: ingredientForm

                            anchors {
                                left: parent.left
                                right: parent.right
                                top:  parent.top
                                bottom: parent.bottom
                                rightMargin: (editable ? removeButton.width + 5 : 0)
                            }

                            Autocomplete {
                                id: name

                                placeholderText: qsTr("Ingredient")
                                width: ingredientForm.width / 2
                                font.pixelSize: Constants.pixelSize
                                horizontalAlignment: Text.AlignLeft
                                text: ingredient.p_name
                                readOnly: {!editable}
                                cursorShape: editable ? Qt.IBeamCursor : Qt.ArrowCursor
                                role: AutocompleteEnum.Ingredient
                                bottomBoundY: root.height
                                anchors {
                                    left: parent.left
                                    right: quantity.left
                                    rightMargin: 5
                                    verticalCenter: parent.verticalCenter
                                }

                                onFocusChanged: {
                                    if (focus) {
                                        var mouseXY = mapToItem(mouseAreaAutocomplete, Qt.rect(name.x, name.y, name.width, name.height))
                                        componentY = mouseXY.y + name.height
                                    }
                                }

                                onEditingFinished: recipe.p_recipe.setNameAt(index, text)
                            }

                            CustomTextField {
                                id: quantity

                                property string quantityProportion: ingredient.p_quantity

                                placeholderText: qsTr("Quantity")
                                width: ingredientForm.width / 2
                                font.pixelSize: Constants.pixelSize
                                selectionColor: Colors.selection
                                selectedTextColor: Colors.text
                                horizontalAlignment: Text.AlignLeft
                                text: editable ? ingredient.p_quantity : quantityProportion
                                readOnly: !editable
                                cursorShape: editable ? Qt.IBeamCursor : Qt.ArrowCursor
                                anchors {
                                    right: parent.right
                                    leftMargin: 5
                                }

                                onEditingFinished: recipe.p_recipe.setQuantityAt(index, text)

                                Connections {
                                    target: plusYieldButton

                                    function onClicked()
                                    {
                                        quantity.quantityProportion = calculateIngredientProportion(ingredient.p_quantity, p_yield, yield.text)
                                    }
                                }

                                Connections {
                                    target: minusYieldButton

                                    function onClicked()
                                    {
                                        quantity.quantityProportion = calculateIngredientProportion(ingredient.p_quantity, p_yield, yield.text)
                                    }
                                }
                            }
                        }

                        CustomButton {
                            id: removeButton

                            width: height
                            height: Constants.height
                            text: '\uFF0D'
                            font.pixelSize: Constants.pixelSize
                            enabled: editable
                            visible: editable
                            anchors {
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                            }

                            onClicked: recipe.p_recipe.removeIngredientAt(index);
                        }
                    }
                }
            }

            states: [
                State {
                    name: "higher"
                    when: listview.height >= listview.width

                    AnchorChanges {
                        target: scrollInstruction

                        anchors {
                            left: parent.left
                            right: parent.right
                            top: imageCheckBox.bottom
                            bottom: rowButtons.top
                        }
                    }
                    AnchorChanges {
                        target: ingredientBox

                        anchors {
                            left: box.right
                            right: parent.right
                            top: title.bottom
                            bottom: scrollInstruction.top
                        }
                    }
                    PropertyChanges {
                        target: scrollInstruction
                        anchors.topMargin: 10
                    }
                    PropertyChanges {
                        target: ingredientBox
                        anchors.topMargin: Constants.margin
                    }
                },
                State {
                    name: "larger"
                    when: listview.width > listview.height

                    AnchorChanges {
                        target: scrollInstruction

                        anchors {
                            left:  box.right
                            right: parent.right
                            top: title.bottom
                            bottom: rowButtons.top
                        }
                    }
                    AnchorChanges {
                        target: ingredientBox

                        anchors {
                            left: parent.left
                            right: scrollInstruction.left
                            top: imageCheckBox.bottom
                            bottom: rowButtons.top
                        }
                    }
                    PropertyChanges {
                        target: scrollInstruction
                        anchors.topMargin: Constants.margin
                    }
                    PropertyChanges {
                        target: ingredientBox
                        anchors.topMargin: 10
                    }
                }
            ]

            RowLayout {
                id: rowButtons

                property var ingredients: []

                height: Constants.height
                width: parent.width * 0.3

                anchors {
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                    bottomMargin: Constants.margin
                }

                CustomButton {
                    text: "Edit"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    font.pixelSize: Constants.pixelSize
                    visible: !editable

                    onClicked: {
                        editable = true

                        yield.text = recipe.p_yield
                        if (rowButtons.ingredients.length == 0) {
                            let count = recipe.p_recipe.rowCount() - 1
                            while (count >= 0) {
                                var ingr = {
                                    name: recipe.p_recipe.name(count),
                                    quantity: recipe.p_recipe.quantity(count)
                                }
                                rowButtons.ingredients.push(ingr)
                                count--
                            }
                        }
                    }

                    CustomToolTip {
                        id: toolTip_update
                    }
                }

                CustomButton {
                    text: "Confirm"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    font.pixelSize: Constants.pixelSize
                    visible: editable

                    onClicked: {
                        let previousImage = recipe.p_pathImage

                        recipe.p_recipe.setTitle(title.text)
                        recipe.p_recipe.setPathImage(recipeImage.source)
                        recipe.p_recipe.setPreparationTime(preparationTime.text)
                        recipe.p_recipe.setCookingTime(cookingTime.text)
                        recipe.p_recipe.setYield(yield.text)
                        recipe.p_recipe.setInstructions(instructionsText.text)
                        rowButtons.ingredients = []
                        if (recipe.p_recipe.updateRecipe()) {
                            let copied = false
                            if (copyImageCheckBox.checked)
                                copied = recipe.p_recipe.copyImage()

                            let deleted = false
                            if (deleteImageCheckBox.checked)
                                deleted = recipe.p_recipe.deleteImage(previousImage)

                            if (copyImageCheckBox.checked === copied && deleteImageCheckBox.checked === deleted) {
                                toolTip_update.text = "Recipe updated :)"
                                toolTip_update.bgColor= Colors.green
                            } else {
                                toolTip_update.text = "Recipe update but some errors occurred :|"
                                if (copyImageCheckBox.checked !== copied)
                                    toolTip_update.text = toolTip_update.text + "\n unable to copy the image"

                                if (deleteImageCheckBox.checked !== deleted)
                                    toolTip_update.text = toolTip_update.text + "\n unable to delete previous image"

                                toolTip_update.bgColor = Colors.orange
                            }
                        } else {
                            toolTip_update.text = "Failed to update recipe :("
                            toolTip_update.bgColor = Colors.red
                        }

                        toolTip_update.open()
                        recipeImage.source = recipe.p_pathImage
                        editable = false
                        recipeImage.imageChanged = false
                        copyImageCheckBox.checked = false
                        deleteImageCheckBox.checked = false
                    }
                }

                CustomButton {
                    text: "Cancel"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    font.pixelSize: Constants.pixelSize
                    visible: editable

                    onClicked: {
                        editable = false
                        recipeImage.imageChanged = false
                        copyImageCheckBox.checked = false
                        deleteImageCheckBox.checked = false

                        recipe.p_recipe.removeAllIngredients()
                        while (rowButtons.ingredients.length > 0) {
                            var ingr = rowButtons.ingredients.pop()
                            recipe.p_recipe.appendIngredient(ingr.name, ingr.quantity)
                        }

                        title.text = recipe.p_title
                        recipeImage.source = recipe.p_pathImage
                        preparationTime.text = recipe.p_preparationTime
                        cookingTime.text = recipe.p_cookingTime
                        yield.text = recipe.p_yield
                        instructionsText.text = recipe.p_instructions
                    }
                }

                CustomButton {
                    text: "Delete"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    font.pixelSize: Constants.pixelSize
                    visible: editable

                    onClicked: {
                        if (recipe.p_recipe.deleteRecipe()) {
                            _selectedRecipes.removeRecipe(index)
                            if (listview.count <= 0)
                                root.visible = false
                        }
                    }
                }
            }
        }
    }

    function calculateIngredientProportion(str, yield, newYield) {
        const regex = /((0+(?=[,\.\/\\])|[1-9])\d*([,\.]\d+|[/\\][1-9]\d*)?)/g;

        let prev = -1
        let cur = -1
        let splitStr = []
        let consecutiveNumber = false
        let result = 1
        let match = regex.exec(str)

        while (match) {
            cur = regex.lastIndex - match[0].length
            
            let notNumber = str.substring(prev, cur)

            consecutiveNumber = /^ +$/.test(notNumber)
            if (consecutiveNumber === false) {
                splitStr.push(notNumber)
                result = 1
            }

            let number = match[1].split(/[/\\]/)

            if (number.length >= 2) {
                result *= Number.parseFloat(number[0]) / Number.parseFloat(number[1])
            } else {
                result *= Number.parseFloat(number[0])
            }

            if (consecutiveNumber === true)
                splitStr.pop()

            splitStr.push((result * newYield / yield).toFixed(2))
            prev = regex.lastIndex
            match = regex.exec(str);
        }

        let newString = "";

        for (const x of splitStr)
            newString += x;

        if (newString === "")
            return str

        newString += str.substring(prev, str.lenght)
        return newString
    }
}

