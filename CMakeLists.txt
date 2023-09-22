cmake_minimum_required(VERSION 3.16)

project(Cookbook LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

enable_testing()

find_package(Qt6 REQUIRED COMPONENTS Sql Quick Gui)
qt_standard_project_setup(REQUIRES 6.5)

find_package(Git REQUIRED)

execute_process(
    COMMAND "${GIT_EXECUTABLE}" rev-parse --abbrev-ref HEAD
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
    OUTPUT_VARIABLE GIT_BRANCH_NAME
    OUTPUT_STRIP_TRAILING_WHITESPACE)

execute_process(
    COMMAND "${GIT_EXECUTABLE}" rev-parse --short HEAD
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
    OUTPUT_VARIABLE GIT_COMMIT_HASH
    OUTPUT_STRIP_TRAILING_WHITESPACE)

add_compile_definitions(GIT_BRANCH_NAME="${GIT_BRANCH_NAME}")
add_compile_definitions(GIT_COMMIT_HASH="${GIT_COMMIT_HASH}")

# https://stackoverflow.com/questions/74854202/qmltyperegistration-include-path-does-not-acknowledge-subdirectories
include_directories(src)

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
    qml/icons/open-in-popup.svg
    qml/icons/github-mark.svg
    qml/icons/github-mark-white.svg
)

qt_add_executable(${PROJECT_NAME}
    src/main.cpp
)

qt_add_qml_module(${PROJECT_NAME}
    URI ${PROJECT_NAME}
    VERSION 1.0
    OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
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
