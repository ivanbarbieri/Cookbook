#include "db_manager.h"
#include "search_recipe.h"
#include "recipes_list.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QScopedPointer>

int main(int argc, char *argv[])
{
    const QString driver{"QSQLITE"};
    const QString connectionName{"cookbook"};
    const QString path{"cookbook.db"};

    QGuiApplication app(argc, argv);
    QScopedPointer<DbManager> db(new DbManager(driver, connectionName, path));

    if (!db->isOpen() || !db->createTables() || !db->createTriggers())
        exit(-1);

    RecipesList selectedRecipes(connectionName);
    QSharedPointer<RecipesList> recipesList(new RecipesList(connectionName));
    SearchRecipe searchRecipe(recipesList);

    QQmlApplicationEngine engine;
    engine.setInitialProperties({
        {"_recipesList", QVariant::fromValue(recipesList.data())},
        {"_searchRecipe", QVariant::fromValue(&searchRecipe)},
        {"_selectedRecipes", QVariant::fromValue(&selectedRecipes)}
    });

    engine.load(QUrl(QStringLiteral("Cookbook/qml/main.qml")));

    return app.exec();
}
