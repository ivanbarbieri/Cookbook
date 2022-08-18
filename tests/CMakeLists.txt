project(tests LANGUAGES CXX)

find_package(Qt6 6.3 REQUIRED COMPONENTS Test Sql Quick Gui)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOMOC ON)

enable_testing(true)

add_executable(tests test_recipe.cpp ../src/db_manager.cpp ../src/recipe.cpp)
add_test(NAME tests COMMAND tests)

target_link_libraries(tests PRIVATE Qt6::Test Qt6::Sql Qt6::Gui Qt6::Quick)
