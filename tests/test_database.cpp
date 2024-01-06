#include "../src/db_manager.h"
#include "../src/recipe.h"

#include <QTest>
#include <QSqlQueryModel>
#include <QSqlQuery>
#include <QScopedPointer>
#include <algorithm>

class TestDatabase : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void cleanupTestCase();
    void triggerUnusedIngredients();

private:
    void emptiesAllTables(const QSqlDatabase &db) const;

private:
    const QString mDriver{"QSQLITE"};
    const QString mConnectionName{"testDatabase"};
    const QString mPath{"testDatabase.db"};
    QScopedPointer<DbManager> db;
};

void TestDatabase::emptiesAllTables(const QSqlDatabase &db) const {
    QSqlQuery query(db);
    for (const auto &table : db.tables())
        query.exec("DELETE FROM " + table);
}

void TestDatabase::initTestCase()
{
    db.reset(new DbManager{mDriver, mConnectionName, mPath});
    QVERIFY(db->isOpen());
    QVERIFY(db->createTables());
    QVERIFY(db->foreignKeys(true));
    QVERIFY(db->createTriggers());
}

void TestDatabase::cleanupTestCase()
{
    db->close();
    QVERIFY(QFile::remove(mPath));
}

void TestDatabase::triggerUnusedIngredients() {
    QSqlDatabase db = QSqlDatabase::database(mConnectionName);
    QSqlQuery query(db);
    query.prepare("SELECT ingredientName FROM ingredients");

    { // 1 recipe with 2 ingredints, delete 1 ingredients, expect only 1 ingredient in the table(ingredients)
        QList <QString> ingredients{"flour", "water"};
        Recipe r;
        r.setConnectionName(mConnectionName);
        for (const auto& ingr: ingredients)
            r.appendIngredient(ingr, "");

        QVERIFY(r.addRecipe());
        r.removeIngredientAt(1);
        QVERIFY(r.updateRecipe());

        if(!query.exec())
            qWarning() << DbManager::errorMessage(query);

        while (query.next()) {
            if (query.value(0).toString().compare("water") == 0)
                QVERIFY(false);
        }
    }

    emptiesAllTables(db);

    { // 1 recipe with 2 ingredients, delete the recipe, expect table(ingredients) to be empty
        QList <QString> ingredients{"flour", "water"};
        Recipe r;
        r.setConnectionName(mConnectionName);
        for (const auto& ingr: ingredients)
            r.appendIngredient(ingr, "");

        QVERIFY(r.addRecipe());
        QVERIFY(r.deleteRecipe());

        if(!query.exec())
            qWarning() << DbManager::errorMessage(query);

        while (query.next())
            QVERIFY(false);
    }

    emptiesAllTables(db);

    { // 2 recipes with the same ingredients, delete 1 recipe, expect all ingredients to still be in the table(ingredients)
        QList <QString> ingredients{"flour", "water"};
        Recipe r, r2;
        r.setConnectionName(mConnectionName);
        for (const auto& ingr: ingredients)
            r.appendIngredient(ingr, "");

        QVERIFY(r.addRecipe());
        r2.setConnectionName(mConnectionName);
        for (const auto& ingr: ingredients)
            r2.appendIngredient(ingr, "");
        QVERIFY(r2.addRecipe());
        QVERIFY(r2.deleteRecipe());

        if(!query.exec())
            qWarning() << DbManager::errorMessage(query);

        while (query.next()) {
            bool found = true;
            for (const auto& str : ingredients) {
                found = query.value(0).toString().compare(str) == 0;
                if (found == true)
                    break;
            }
            if (found == false)
                QVERIFY(false);
        }
    }

    emptiesAllTables(db);

    { // r2 has an ingredient that r1 doesn't have, eliminating r2 should leave only the common ingredient in the table(ingredients)
        QList <QString> ingredients{"flour", "water"};
        Recipe r, r2;
        r.setConnectionName(mConnectionName);
        r.appendIngredient(ingredients.at(0), "");

        QVERIFY(r.addRecipe());

        r2.setConnectionName(mConnectionName);
        for (const auto& ingr: ingredients)
            r2.appendIngredient(ingr, "");

        QVERIFY(r2.addRecipe());
        QVERIFY(r2.deleteRecipe());

        if(!query.exec())
            qWarning() << DbManager::errorMessage(query);

        while (query.next()) {
            if (query.value(0).toString().compare(ingredients.at(1)) == 0)
                QVERIFY(false);
        }
    }
}

QTEST_MAIN(TestDatabase)
#include "test_database.moc"
