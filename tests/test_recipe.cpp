#include "../src/db_manager.h"
#include "../src/recipe.h"

#include <QTest>
#include <QSqlQueryModel>
#include <QSqlQuery>
#include <QScopedPointer>
#include <QFile>

class TestRecipe : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void cleanupTestCase();
    void getIngredients_empty();
    void getIngredients();
    void updateRecipe();
    void updateOnlyOneIngredient();
    void updateAddIngredient();
    void updateRemoveOneIngrdient();

private:
    const QString mDriver{"QSQLITE"};
    const QString mConnectionName{"testDatabase"};
    const QString mPath{"testDatabase.db"};

    QScopedPointer<DbManager> db;
};



void TestRecipe::initTestCase()
{
    db.reset(new DbManager{mDriver, mConnectionName, mPath});
    QVERIFY(db->isOpen());
    QVERIFY(db->createTables());
    QVERIFY(db->createTriggers());
}

void TestRecipe::cleanupTestCase()
{
    db->close();
    QVERIFY(QFile::remove(mPath));
}

void TestRecipe::getIngredients_empty()
{
    Recipe rSample{mConnectionName, -1, "path/image", "0 ingr", 0, 0, 0, "instructions",
                QList<Recipe::Ingredient*>()};
    rSample.addRecipe();
    Recipe r;
    r.setConnectionName(mConnectionName);
    r.setRecipeId(rSample.recipeId());
    r.getIngredients();
    QVERIFY2(r.isEmpty(), "There are ingredients but there shouldn't be any");
}

void TestRecipe::getIngredients()
{
    Recipe rSample{mConnectionName, -1, "path/image", "2 ingr", 0, 0, 0, "instructions",
                QList<Recipe::Ingredient*>({
                                               new Recipe::Ingredient{"Flour", ""},
                                               new Recipe::Ingredient{"Water", ""}
                                           })};
    rSample.addRecipe();
    Recipe r;
    r.setConnectionName(mConnectionName);
    r.setRecipeId(rSample.recipeId());
    r.getIngredients();
    QCOMPARE(r.ingredientsList().size(), rSample.ingredientsList().size());
    for (qsizetype i = 0; i < r.ingredientsList().size(); i++) {
        QCOMPARE(r.ingredientsList().at(i)->name, rSample.ingredientsList().at(i)->name);
        QCOMPARE(r.ingredientsList().at(i)->quantity, rSample.ingredientsList().at(i)->quantity);
    }
}

void TestRecipe::updateRecipe()
{
    Recipe r;
    r.setConnectionName(mConnectionName);
    r.addRecipe();

    r.setPathImage("newPath");
    r.setTitle("newTitle");
    r.setPreparationTime(1);
    r.setCookingTime(1);
    r.setYield(1);
    r.setInstructions("newInstructions");
    r.appendIngredient("newIngr", "newQuant");
    r.updateRecipe();

    QSqlDatabase db = QSqlDatabase::database(mConnectionName);
    QSqlQuery query(db);
    query.prepare("SELECT pathImage, title, preparationTime, cookingTime, yield, instructions, ingredientName, quantity "
                    "FROM recipes"
                    "WHERE recipeId LIKE :recipeId");
    query.bindValue(":recipeId", r.recipeId());
    QVERIFY2(!query.exec(), DbManager::errorMessage(query).toLocal8Bit().constData());
    while (query.next()) {
        QCOMPARE(query.value(0).toString(), r.pathImage());
        QCOMPARE(query.value(1).toString(), r.title());
        QCOMPARE(query.value(2).toInt(), r.preparationTime());
        QCOMPARE(query.value(3).toInt(), r.cookingTime());
        QCOMPARE(query.value(4).toInt(), r.yield());
        QCOMPARE(query.value(5).toString(), r.instructions());
    }

    Recipe recipeIngr;
    recipeIngr.setConnectionName(mConnectionName);
    recipeIngr.setRecipeId(r.recipeId());
    recipeIngr.getIngredients();
    QCOMPARE(recipeIngr.ingredientsList().size(), r.ingredientsList().size());
    for (qsizetype i = 0; i < r.ingredientsList().size(); i++) {
        QCOMPARE(recipeIngr.ingredientsList().at(i)->name, r.ingredientsList().at(i)->name);
        QCOMPARE(recipeIngr.ingredientsList().at(i)->quantity, r.ingredientsList().at(i)->quantity);
    }
}

void TestRecipe::updateOnlyOneIngredient()
{
    Recipe r;
    r.setConnectionName(mConnectionName);
    r.appendIngredient("Flour", "500");
    r.appendIngredient("Water", "250");
    r.addRecipe();

    r.setNameAt(0, "00 Flour");
    r.setQuantityAt(0, "400");
    r.updateRecipe();

    Recipe recipeIngr;
    recipeIngr.setConnectionName(mConnectionName);
    recipeIngr.setRecipeId(r.recipeId());
    recipeIngr.getIngredients();
    QCOMPARE(recipeIngr.ingredientsList().size(), r.ingredientsList().size());
    QCOMPARE(recipeIngr.ingredientsList().at(0)->name, "00 Flour");
    QCOMPARE(recipeIngr.ingredientsList().at(0)->quantity, "400");
    QCOMPARE(recipeIngr.ingredientsList().at(1)->name, r.ingredientsList().at(1)->name);
    QCOMPARE(recipeIngr.ingredientsList().at(1)->quantity, r.ingredientsList().at(1)->quantity);
}

void TestRecipe::updateAddIngredient()
{
    Recipe r;
    r.setConnectionName(mConnectionName);
    r.appendIngredient("Flour", "500");
    r.appendIngredient("Water", "250");
    r.addRecipe();

    r.appendIngredient("Salt", "10");
    r.updateRecipe();

    Recipe recipeIngr;
    recipeIngr.setConnectionName(mConnectionName);
    recipeIngr.setRecipeId(r.recipeId());
    recipeIngr.getIngredients();
    QCOMPARE(recipeIngr.ingredientsList().size(), r.ingredientsList().size());
    QVERIFY2([&]() -> bool {
        for (qsizetype i = 0; i < r.ingredientsList().size(); i++) {
            if (recipeIngr.name(i).compare("Salt") == 0)
                return true;
        }
        return false;
    }(), "The ingredient to add wasn't found");
}

void TestRecipe::updateRemoveOneIngrdient()
{
    Recipe r;
    r.setConnectionName(mConnectionName);
    r.appendIngredient("Flour", "500");
    r.appendIngredient("Water", "250");
    r.addRecipe();

    r.removeIngredientAt(1);
    r.updateRecipe();

    Recipe recipeIngr;
    recipeIngr.setConnectionName(mConnectionName);
    recipeIngr.setRecipeId(r.recipeId());
    recipeIngr.getIngredients();
    QCOMPARE(recipeIngr.ingredientsList().size(), r.ingredientsList().size());
    for (qsizetype i = 0; i < r.ingredientsList().size(); i++) {
        if (recipeIngr.name(i).compare("Water") == 0)
            QVERIFY2(false, "The ingredient that had to be removed was found");
    }
}

QTEST_MAIN(TestRecipe)
#include "test_recipe.moc"
