#include "db_manager.h"

#include <QDebug>
#include <QSqlError>
#include <QSqlQuery>

DbManager::DbManager(const QString &path)
{
    db = QSqlDatabase::addDatabase("QSQLITE", "cookbook");
    db.setDatabaseName(path);

    if (db.open()) {
        qDebug() << "Database: connection ok";
    } else {
        qDebug() << "Error: connection with database fail";
    }
}

DbManager::~DbManager()
{
    if (db.isOpen())
        db.close();
}

bool DbManager::isOpen() const
{
    return db.isOpen();
}

bool DbManager::createTables()
{
    QVector <QString> queries {
        "CREATE TABLE IF NOT EXISTS recipes ("
        "recipeId INTEGER PRIMARY KEY AUTOINCREMENT,"
        "recipeTitle TEXT,"
        "pathImage TEXT,"
        "preparationTime INTEGER,"
        "cookingTime INTEGER,"
        "yield TEXT,"
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

    QSqlQuery query(QSqlDatabase::database("cookbook"));
    for (auto q :  queries) {
        query.prepare(q);
        if (!query.exec()) {
            qDebug() << query.lastError().text();
            return false;
        }
    }
    return true;
}
