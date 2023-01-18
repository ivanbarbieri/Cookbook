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
    color: Colors.darkGrey
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
        property int currentIndex: 0
        property int prevIndex: 0

        height: 25
        anchors {left: parent.left; right: parent.right; top: parent.top}
        orientation: ListView.Horizontal
        spacing: 1
        model: _selectedRecipes
        delegate: Rectangle {
            height: 25
            width: 100
            color: Colors.darkGrey

            Text {
                height: parent.height
                width: parent.width * 0.75
                anchors {left: parent.left; right: removeTab.left; top: parent.top; bottom: parent.bottom; margins: 2}
                text: _selectedRecipes.recipe(index).title ?? ""
                color: Colors.white

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (tabBar.prevIndex >= 0) {
                            tabBar.itemAtIndex(tabBar.prevIndex).color = Colors.darkGrey
                            tabBar.prevIndex = index
                        }
                        tabBar.currentIndex = index
                        tabBar.itemAtIndex(index).color = Colors.lightGrey
                        listview.positionViewAtIndex(index, ListView.Contain)
                    }
                }
            }

            Button {
                id: removeTab

                height: parent.height
                width: parent.width * 0.25
                anchors {right: parent.right; top: parent.top; bottom: parent.bottom}
                text: "X"
                onClicked: {
                    _selectedRecipes.removeRecipe(index)
                    if (listview.count <= 0)
                        root.visible = false
                        
                    if (tabBar.prevIndex >= listview.count)
                            tabBar.prevIndex = 0
                }
            }
        }
    }

    ListView {
        id: listview

        clip: true
        anchors {left: parent.left; right: parent.right; top: tabBar.bottom; bottom: parent.bottom}
        interactive: false

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

            height: listview.height
            width: listview.width

            CustomTextField {
                id: title

                placeholderText: qsTr("Title")
                text: recipe.p_title
                height:  35 + 0.03 * parent.height
                font.pixelSize: height - 8
                readOnly: {!editable}
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Constants.margin
                }
            }

            Image {
                id: recipeImage

                width: Math.min(listview.width, listview.height) * 0.3
                height: width
                fillMode: Image.PreserveAspectFit
                source: recipe.p_pathImage

                anchors {
                    left: parent.left
                    top: title.bottom
                    margins: Constants.margin
                }

                asynchronous : true

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
                    color: Colors.white
                }

                CustomTextField {
                    id: preparationTime

                    text: recipe.p_preparationTime
                    validator: RegularExpressionValidator { regularExpression: /\d*/ }
                    readOnly: {!editable}
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                }

                Label {
                    text: qsTr("Cooking time")
                    color: Colors.white
                }

                CustomTextField {
                    id: cookingTime

                    text: recipe.p_cookingTime
                    validator: RegularExpressionValidator { regularExpression: /\d*/ }
                    readOnly: {!editable}
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                }

                Label {
                    text: qsTr("Yield")
                    color: Colors.white
                }

                CustomTextField {
                    id: yield

                    text: recipe.p_yield
                    validator: RegularExpressionValidator { regularExpression: /\d*/ }
                    readOnly: !editable
                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                }
                Row {
                    id: yieldButtons

                    signal yieldButtonClicked(str: string, oldYield: int, newYield: int)
                    spacing: width * 0.25
                    anchors.horizontalCenter: yield.horizontalCenter
                    visible: !editable

                    CustomButton {
                        id: minusYieldButton
                        text: '-'
                        height: yield.height
                        width: yield.height
                        onClicked: {
                            yield.text = Number(yield.text) > 0 ? Number(yield.text) - 1 : 0
                        }
                    }

                    CustomButton {
                        id: plusYieldButton
                        text: '+'
                        height: yield.height
                        width: yield.height
                        onClicked: {
                            yield.text = Number(yield.text) + 1
                        }
                    }

                }
            }

            ScrollView {
                id: scrollInstruction
                width: (parent.width + anchors.rightMargin + anchors.leftMargin)/2
                clip: true

                anchors {
                    left: parent.left
                    right: parent.right
                    top: recipeImage.bottom
                    bottom: rowButtons.top
                    margins: Constants.margin
                }

                ScrollBar.vertical: CustomScrollBar {
                    anchors.top: scrollInstruction.top
                    anchors.right: scrollInstruction.right
                    anchors.bottom: scrollInstruction.bottom
                }

                TextArea {
                    id: instructionsText

                    placeholderText: qsTr("Instructions")
                    text: p_instructions
                    selectionColor: Colors.darkGrey
                    selectedTextColor: Colors.white
                    wrapMode: Text.Wrap
                    font.pixelSize: 15
                    readOnly: {!editable}
                    background: Rectangle {
                        color: Colors.grey
                        radius: Constants.radius
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
                    margins: Constants.margin
                }

                CustomButton {
                    id: addIngredientButton

                    text: 'Add ingredient'
                    height: 23
                    enabled: editable
                    visible: editable
                    anchors {
                        left: parent.left
                        right: parent.right
                        rightMargin: 10
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

                        width: ingredientsList.width - ingredientsListScrollBar.width
                        height: Math.max(name.height, quantity.height)
                        anchors.rightMargin: 5


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
                                id: name
                                
                                role: AutocompleteEnum.Ingredient
                                bottomBoundY: root.height
                                placeholderText: qsTr("Ingredient")
                                width: ingredientForm.width / 2
                                horizontalAlignment: Text.AlignLeft
                                text: ingredient.p_name
                                readOnly: {!editable}
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
                                selectionColor: Colors.darkGrey
                                selectedTextColor: Colors.white
                                horizontalAlignment: Text.AlignLeft
                                text: editable ? ingredient.p_quantity : quantityProportion
                                readOnly: !editable
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

                            width: 23
                            height: width
                            text: "\u2212"
                            font.pixelSize: 15
                            bottomPadding: 10
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
                            top: recipeImage.bottom
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
                            top: recipeImage.bottom
                            bottom: rowButtons.top
                        }
                    }
                }
            ]

            RowLayout {
                id: rowButtons
                property var ingredients: []

                height: 20
                width: parent.width * 0.3

                anchors {
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                    bottomMargin: Constants.margin
                }

                CustomButton {
                    text: "Edit"
                    Layout.fillWidth: true
                    font.pixelSize: 15
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

                    ToolTip {
                        id: toolTip_update

                        timeout: 1500
                        contentItem: Text {
                            text: toolTip_update.text
                        }
                        background: Rectangle {
                            width: toolTip_update.text.width
                            border.width: 3
                            radius: Constants.radius
                            color: Colors.lightGrey
                        }
                    }
                }

                CustomButton {
                    text: "Confirm"
                    Layout.fillWidth: true
                    font.pixelSize: 15
                    visible: editable

                    onClicked: {
                        editable = false
                        recipe.p_recipe.setTitle(title.text)
                        recipe.p_recipe.setPathImage(recipeImage.source);
                        recipe.p_recipe.setPreparationTime(preparationTime.text)
                        recipe.p_recipe.setCookingTime(cookingTime.text)
                        recipe.p_recipe.setYield(yield.text)
                        recipe.p_recipe.setInstructions(instructionsText.text)
                        rowButtons.ingredients = []

                        if (recipe.p_recipe.updateRecipe()) {
                            toolTip_update.text = "Successful update :)"
                            toolTip_update.text.color = Colors.green
                            toolTip_update.background.border.color = Colors.green
                        } else {
                            toolTip_update.text = "Update failed :("
                            toolTip_update.text.color = Colors.red
                            toolTip_update.background.border.color = Colors.red
                        }
                        toolTip_update.open()
                    }
                }

                CustomButton {
                    text: "Cancel"
                    Layout.fillWidth: true
                    font.pixelSize: 15
                    visible: editable

                    onClicked: {
                        editable = false

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
                    font.pixelSize: 15
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

        return newString
    }
}

