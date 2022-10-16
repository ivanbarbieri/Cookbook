cmake_minimum_required(VERSION 3.16)

project(Cookbook LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

enable_testing()

find_package(Qt6 6.3 COMPONENTS Sql Quick Gui REQUIRED)
qt_standard_project_setup()

set(header
    src/db_manager.h
    src/recipe.h
    src/recipes_list.h
    src/search_recipe.h
    src/autocomplete.h
)

set(sources
    src/main.cpp
    src/db_manager.cpp
    src/recipe.cpp
    src/recipes_list.cpp
    src/search_recipe.cpp
    src/autocomplete.cpp
)

set(qml
    qml/AddRecipe.qml
    qml/main.qml
    qml/RecipeWindow.qml
    qml/SearchRecipe.qml
    qml/SearchRecipeForm.qml
    qml/Autocomplete.qml
)

set(resources
    qml/icons/placeholder.svg
)

qt_add_executable(${PROJECT_NAME}
    src/main.cpp
)

qt_add_qml_module(${PROJECT_NAME}
    URI ${PROJECT_NAME}
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
add_subdirectory(tests)

target_link_libraries(${PROJECT_NAME} PRIVATE Qt6::Sql Qt6::Gui Qt6::Quick Constants CustomModules)

set_target_properties(${PROJECT_NAME} PROPERTIES
    # Prevent the creation of a console window on Windows.
    WIN32_EXECUTABLE ON
)
