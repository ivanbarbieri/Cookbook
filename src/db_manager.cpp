#include "db_manager.h"

#include <QDebug>
#include <QSqlError>
#include <QSqlQuery>

DbManager::DbManager()
{
}

DbManager::DbManager(const QString &driver, const QString &connectionName, const QString &path)
{
    db = QSqlDatabase::addDatabase(driver, connectionName);
    db.setDatabaseName(path);
    if (!db.open())
        qFatal("Error: connection with database fail");
}

DbManager::~DbManager()
{
    close();
}

const QString DbManager::errorMessage(const QSqlQuery &query)
{
    return "SqLite error:" + query.lastError().text() +
            "\nSqLite type code: " + QString::number(query.lastError().type());
}

bool DbManager::foreignKeys(bool active) const
{
    QSqlQuery query(db);
    QString stmt;

    if (active)
        stmt = "PRAGMA foreign_keys = ON";
    else
        stmt = "PRAGMA foreign_keys = OFF";

    if (!query.exec(stmt)) {
        qWarning() << errorMessage(query);
        return false;
    }

    return true;
}

void DbManager::close()
{
    if (db.isOpen())
        db.close();
}

bool DbManager::isOpen() const
{
    return db.isOpen();
}

bool DbManager::createTables() const
{
    const QVector <QString> queries {
        "CREATE TABLE IF NOT EXISTS recipes ("
        "recipeId INTEGER PRIMARY KEY AUTOINCREMENT,"
        "title TEXT,"
        "pathImage TEXT,"
        "preparationTime INTEGER,"
        "cookingTime INTEGER,"
        "yield INTEGER,"
        "instructions TEXT)"
        ,
        "CREATE TABLE IF NOT EXISTS ingredients ("
        "ingredientId INTEGER PRIMARY KEY AUTOINCREMENT,"
        "ingredientName TEXT UNIQUE ON CONFLICT IGNORE)"
        ,
        "CREATE TABLE IF NOT EXISTS recipes_ingredients ("
        "recipeId INTEGER NOT NULL,"
        "ingredientId INTEGER NOT NULL,"
        "quantity TEXT,"
        "FOREIGN KEY (recipeId)"
        "  REFERENCES recipes (recipeId) ON DELETE CASCADE"
        "                                ON UPDATE NO ACTION,"
        "FOREIGN KEY (ingredientId)"
        "  REFERENCES ingredients (ingredientId) ON DELETE CASCADE"
        "                                        ON UPDATE NO ACTION)"
    };

    QSqlQuery query(db);
    for (const auto &q :  queries) {
        query.prepare(q);
        if (!query.exec()) {
            qWarning() << errorMessage(query);
            return false;
        }
    }
    return true;
}

bool DbManager::createTriggers() const
{
    QSqlQuery query(db);
    if (!query.exec("CREATE TRIGGER IF NOT EXISTS delete_unused_ingredients_on_recipes_ingredients"
                    " AFTER DELETE ON recipes_ingredients"
                    " BEGIN"
                    "   DELETE FROM ingredients"
                    "   WHERE ingredientId NOT IN ("
                    "       SELECT ingredientId FROM recipes_ingredients);"
                    " END")) {
        qWarning() << errorMessage(query);
        return false;
    }
    if (!query.exec("CREATE TRIGGER IF NOT EXISTS delete_unused_ingredients_on_recipes"
                    " AFTER DELETE ON recipes"
                    " BEGIN"
                    "   DELETE FROM recipes_ingredients"
                    "   WHERE ingredientId NOT IN ("
                    "       SELECT ingredientId FROM recipes);"
                    " END")) {
        qWarning() << errorMessage(query);
        return false;
    }
    return true;
}
