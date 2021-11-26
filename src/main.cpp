#include "db_manager.h"
#include "add_recipe.h"
#include "show_recipe.h"
#include "search_recipe.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

int main(int argc, char *argv[])
{
    const QString path = "cookbook.db";

    DbManager db(path);
    if (db.isOpen()) {
        if (db.createTables()) {
            qDebug() << "Tables created";
        } else {
            exit(-1);
        }
    } else {
        qDebug() << "Connection with database fail" << Qt::endl;
        exit(-1);
    }

    QGuiApplication app(argc, argv);

    AddRecipe addRecipe;
    ShowRecipe showRecipe;
    SearchRecipe searchRecipe(nullptr, &showRecipe);

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("_showRecipe", &showRecipe);
    engine.rootContext()->setContextProperty("_searchRecipe", &searchRecipe);
    engine.rootContext()->setContextProperty("_addRecipe", &addRecipe);
    engine.addImportPath(":/imports");
    engine.load(QUrl(QLatin1String("qrc:/main.qml")));

    return app.exec();
}
