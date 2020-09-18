#include "db_manager.h"

#include <QDebug>
#include <QSqlError>
#include <QSqlQuery>
#include <string>

DbManager::DbManager(const QString &path)
{
    db = QSqlDatabase::addDatabase("QSQLITE");
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
    QString queries[] = {"CREATE TABLE IF NOT EXISTS recipes ("
                         "recipeId INTEGER PRIMARY KEY,"
                         "recipeName TEXT NOT NULL,"
                         "preparationTime TEXT DEFAULT '?',"
                         "cookTime TEXT DEFAULT '?',"
                         "totalTime TEXT DEFAULT '?',"
                         "yield TEXT DEFAULT '?',"
                         "instructions TEXT);"
                         ,
                         "CREATE TABLE IF NOT EXISTS ingredients ("
                         "ingredientId INTEGER PRIMARY KEY,"
                         "ingredientName TEXT NOT NULL,"
                         "quantity TEXT);"
                         ,
                         "CREATE TABLE IF NOT EXISTS recipes_ingredients ("
                         "recipeId INTEGER NOT NULL,"
                         "ingredientId INTEGER NOT NULL,"
                         "quantity TEXT NOT NULL,"
                         "FOREIGN KEY (recipeId)"
                         "  REFERENCES recipes (recipeId) ON DELETE CASCADE"
                         "                                ON UPDATE NO ACTION,"
                         "FOREIGN KEY (ingredientId)"
                         "  REFERENCES ingredients (ingredientId) ON DELETE CASCADE"
                         "                                        ON UPDATE NO ACTION);"
                         ,
                         nullptr
                        };

    for (int i = 0; queries[i] != nullptr; i++) {
        QSqlQuery query;
        query.prepare(queries[i]);
        if (!query.exec()) {
            qDebug() << "Database: table couldn't be created:" << Qt::endl
                     << queries[i] << Qt::endl;
            return false;
        }
    }
    return true;
}

