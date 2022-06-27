#include "db_manager.h"
#include "recipe.h"
#include "search_recipe.h"
#include "recipes_list.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[])
{
    const QString path = "cookbook.db";

    DbManager db(path);
    if (!db.isOpen() || !db.createTables() || !db.createTriggers())
        exit(-1);

    QGuiApplication app(argc, argv);
    RecipesList selectedRecipes;
    RecipesList recipesList;
    SearchRecipe searchRecipe(&recipesList);

    QQmlApplicationEngine engine;
    engine.setInitialProperties({
        {"_recipesList", QVariant::fromValue(&recipesList)},
        {"_searchRecipe", QVariant::fromValue(&searchRecipe)},
        {"_selectedRecipes", QVariant::fromValue(&selectedRecipes)}
    });

    engine.addImportPath("qrc:/imports");
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
