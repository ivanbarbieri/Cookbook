#include "db_manager.h"
#include "search_recipe.h"
#include "recipes_list.h"
#include "autocomplete.h"

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

    if (!db->isOpen() || !db->createTables() || !db->foreignKeys(true) || !db->createTriggers())
        exit(-1);

    QSharedPointer<RecipesList> recipesList(new RecipesList(connectionName));
    SearchRecipe searchRecipe(recipesList);
    RecipesList selectedRecipes(connectionName);
    Autocomplete autocomplete(connectionName);

    const QString qtVersion = QString("Qt Version: %1.%2.%3\n").arg(QT_VERSION_MAJOR).arg(QT_VERSION_MINOR).arg(QT_VERSION_PATCH);
    const QString commitHash = QString("Git commit hash: %1").arg(GIT_COMMIT_HASH);

    QQmlApplicationEngine engine;
    engine.setInitialProperties({
        {"_buildInfos", QString(qtVersion + commitHash)},
        {"_recipesList", QVariant::fromValue(recipesList.data())},
        {"_searchRecipe", QVariant::fromValue(&searchRecipe)},
        {"_selectedRecipes", QVariant::fromValue(&selectedRecipes)},
        {"_autocomplete", QVariant::fromValue(&autocomplete)}
    });

    qmlRegisterUncreatableType<Autocomplete>("AutocompleteEnum", 1, 0, "AutocompleteEnum", "Not creatable as it is an enum type");

    engine.load(QUrl(QStringLiteral("qml/main.qml")));

    return app.exec();
}
