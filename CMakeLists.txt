cmake_minimum_required(VERSION 3.16)

project(Cookbook LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.3 COMPONENTS Sql Quick Gui REQUIRED)
qt_standard_project_setup()

set(header
    src/db_manager.h
    src/recipe.h
    src/recipes_list.h
    src/search_recipe.h
)

set(sources
    src/main.cpp
    src/db_manager.cpp
    src/recipe.cpp
    src/recipes_list.cpp
    src/search_recipe.cpp
)

set(qml
    qml/AddRecipe.qml
    qml/main.qml
    qml/RecipeWindow.qml
    qml/SearchRecipe.qml
    qml/SearchRecipeForm.qml
)

set(resources
    qml/icons/placeholder.svg
)

qt_add_executable(Cookbook
    src/main.cpp
)

qt_add_qml_module(Cookbook
    URI Cookbook
    VERSION 1.0
    SOURCES
        ${sources}
        ${header}
    QML_FILES
        ${qml}
    RESOURCES
        ${resources}
)

add_subdirectory(qml/imports/Constants)
add_subdirectory(qml/imports/CustomModules)

target_link_libraries(Cookbook PRIVATE Qt6::Sql Qt6::Gui Qt6::Quick Constants CustomModules)

set_target_properties(Cookbook PROPERTIES
    # Prevent the creation of a console window on Windows.
    WIN32_EXECUTABLE ON
)
