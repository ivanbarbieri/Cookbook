project(tests LANGUAGES CXX)

find_package(Qt6 6.3 REQUIRED COMPONENTS Test Sql Quick Gui)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
enable_testing(true)

add_executable(test_recipe test_recipe.cpp
    ../src/db_manager.cpp
    ../src/recipe.cpp
)
add_test(NAME test_recipe COMMAND tests)
target_link_libraries(test_recipe PRIVATE Qt6::Test Qt6::Sql Qt6::Gui Qt6::Quick)

add_executable(test_search_recipe test_search_recipe.cpp
    ../src/db_manager.cpp
    ../src/recipe.cpp
    ../src/recipes_list.cpp
    ../src/search_recipe.cpp
)
add_test(NAME test_search_recipe COMMAND tests)
target_link_libraries(test_search_recipe PRIVATE Qt6::Test Qt6::Sql Qt6::Gui Qt6::Quick)

add_executable(test_autocomplete test_autocomplete.cpp
    ../src/db_manager.cpp
    ../src/recipe.cpp
    ../src/autocomplete.cpp
)
add_test(NAME test_autocomplete COMMAND tests)
target_link_libraries(test_autocomplete PRIVATE Qt6::Test Qt6::Sql Qt6::Gui Qt6::Quick)
