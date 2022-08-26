#include "../src/db_manager.h"
#include "../src/recipe.h"
#include "../src/recipes_list.h"
#include "../src/search_recipe.h"

#include <QTest>
#include <QScopedPointer>
#include <QSharedPointer>
#include <QFile>
#include <QVariant>
#include <QSet>

class TestSearchRecipe : public QObject
{
    Q_OBJECT

private:
    bool compare(const QSet<int> &expectedId) const noexcept;
    void appendIngredients(const QList<QString>& ingredients) const noexcept;

private slots:
    void initTestCase();
    void cleanupTestCase();
    void init();
    void cleanup();

    void searchAll();
    void searchSubstringInTitle();
    void searchUsingTitleAndIngredients();
    void searchUsingOnlyIngredients();


private:
    const QString mDriver{"QSQLITE"};
    const QString mConnectionName{"testDatabase"};
    const QString mPath{"testDatabase.db"};

    QList<Recipe*> mRecipes {
        new Recipe{mConnectionName, -1, "path/image", "Diet", 0, 0, 0, "instructions", QList<Recipe::Ingredient*>()},
        new Recipe{mConnectionName, -1, "path/image", "Flour", 0, 0, 0, "instructions", QList<Recipe::Ingredient*>(
                        {
                            new Recipe::Ingredient{"Flour", ""}
                        })},
        new Recipe{mConnectionName, -1, "path/image", "Wet flour", 0, 0, 0, "instructions", QList<Recipe::Ingredient*>(
                        {
                            new Recipe::Ingredient{"Flour", ""},
                            new Recipe::Ingredient{"Water", ""}
                        })},
        new Recipe{mConnectionName, -1, "path/image", "Wet flour with eggs", 0, 0, 0, "instructions", QList<Recipe::Ingredient*>(
                        {
                            new Recipe::Ingredient{"Flour", ""},
                            new Recipe::Ingredient{"Water", ""},
                            new Recipe::Ingredient{"Eggs", ""}
                        })},
        new Recipe{mConnectionName, -1, "path/image", "Wet 00 flour", 0, 0, 0, "instructions", QList<Recipe::Ingredient*>(
                        {
                            new Recipe::Ingredient{"00 flour", ""},
                            new Recipe::Ingredient{"Water", ""}
                        })}
    };

    QScopedPointer<DbManager> db;
    QSharedPointer<RecipesList> mRecipesList;
    QScopedPointer<SearchRecipe> mSearchRecipe;
};

bool TestSearchRecipe::compare(const QSet<int> &expectedId) const noexcept
{
    for (int i = 0; i < mRecipesList->rowCount(); i++) {
        auto r = mRecipesList->recipe(i).value<Recipe*>();
        if (!expectedId.contains(r->recipeId()))
            return false;
    }
    return true;
}

void TestSearchRecipe::appendIngredients(const QList<QString>& ingredients) const noexcept
{
    int i = 0;
    for (const auto &ingr : ingredients) {
        mSearchRecipe->appendIngredient();
        mSearchRecipe->setIngredientAt(i, ingr);
        i++;
    }
}

void TestSearchRecipe::initTestCase()
{
    db.reset(new DbManager{mDriver, mConnectionName, mPath});
    QVERIFY(db->isOpen());
    QVERIFY(db->createTables());

    for (const auto &r : mRecipes)
        QVERIFY(r->addRecipe());

    mRecipesList.reset(new RecipesList{mConnectionName});
    mSearchRecipe.reset(new SearchRecipe(mRecipesList.get()));
}

void TestSearchRecipe::cleanupTestCase()
{
    db->close();
    QVERIFY(QFile::remove(mPath));
}

void TestSearchRecipe::init()
{
    mSearchRecipe.reset(new SearchRecipe(mRecipesList.get()));
}

void TestSearchRecipe::cleanup()
{
    mRecipesList->removeAllRecipes();
}

void TestSearchRecipe::searchAll()
{
    mSearchRecipe->search("");
    const QSet<int> expectedId{mRecipes.at(0)->recipeId(),
                mRecipes.at(1)->recipeId(),
                mRecipes.at(2)->recipeId(),
                mRecipes.at(3)->recipeId(),
                mRecipes.at(4)->recipeId()};
    QCOMPARE(mRecipesList->rowCount(), expectedId.size());
    QVERIFY(compare(expectedId));
}

void TestSearchRecipe::searchSubstringInTitle()
{

    {
        mSearchRecipe->search("Flour");
        const QSet<int> expectedId{mRecipes.at(1)->recipeId(),
                    mRecipes.at(2)->recipeId(),
                    mRecipes.at(3)->recipeId(),
                    mRecipes.at(4)->recipeId()};
        QCOMPARE(mRecipesList->rowCount(), expectedId.size());
        QVERIFY(compare(expectedId));
    }

    {
        mSearchRecipe->search("Wet flour");
        const QSet<int> expectedId{mRecipes.at(2)->recipeId(),
                    mRecipes.at(3)->recipeId()};
        QCOMPARE(mRecipesList->rowCount(), expectedId.size());
        QVERIFY(compare(expectedId));
    }
}

void TestSearchRecipe::searchUsingTitleAndIngredients()
{

    {
        appendIngredients({"flour"});
        mSearchRecipe->search("flour");
        const QSet<int> expectedId{mRecipes.at(1)->recipeId(),
                    mRecipes.at(2)->recipeId(),
                    mRecipes.at(3)->recipeId(),
                    mRecipes.at(4)->recipeId()};
        QCOMPARE(mRecipesList->rowCount(), expectedId.size());
        QVERIFY(compare(expectedId));
    }

    {
        appendIngredients({"Flour", "Water"});
        mSearchRecipe->search("flour");
        const QSet<int> expectedId{mRecipes.at(2)->recipeId(),
                    mRecipes.at(3)->recipeId(),
                    mRecipes.at(4)->recipeId()};
        QCOMPARE(mRecipesList->rowCount(), expectedId.size());
        QVERIFY(compare(expectedId));
    }
}

void TestSearchRecipe::searchUsingOnlyIngredients()
{

    {
        mSearchRecipe->appendIngredient();
        mSearchRecipe->search("");
        const QSet<int> expectedId{mRecipes.at(1)->recipeId(),
                    mRecipes.at(2)->recipeId(),
                    mRecipes.at(3)->recipeId(),
                    mRecipes.at(4)->recipeId()};
        QVERIFY(compare(expectedId));
    }

    {
        appendIngredients({"Flour", "Water"});
        mSearchRecipe->search("");
        const QSet<int> expectedId {mRecipes.at(2)->recipeId(),
                    mRecipes.at(3)->recipeId(),
                    mRecipes.at(4)->recipeId()};
        QCOMPARE(mRecipesList->rowCount(), expectedId.size());
        QVERIFY(compare(expectedId));
    }
}

QTEST_MAIN(TestSearchRecipe)
#include "test_search_recipe.moc"
