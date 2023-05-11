qt_add_qml_module (CustomModules
    URI qml.imports.CustomModules
    VERSION 1.0
    OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/qml/imports/CustomModules
    QML_FILES
        CustomButton.qml
        CustomCheckBox.qml
        CustomScrollBar.qml
        CustomTextArea.qml
        CustomTextField.qml
        CustomToolTip.qml
)


