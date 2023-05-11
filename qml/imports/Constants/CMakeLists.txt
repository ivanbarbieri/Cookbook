set_source_files_properties(
    Constants.qml
    Colors.qml
    PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(Constants
    URI qml.imports.Constants
    VERSION 1.0
    OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/qml/imports/Constants
    QML_FILES
        Constants.qml
        Colors.qml
)

