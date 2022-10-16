#include "../src/autocomplete.h"
#include "../src/db_manager.h"
#include "../src/recipe.h"

#include <QTest>
#include <QScopedPointer>
#include <QFile>
#include <QSet>

class TestAutocomplete : public QObject
{
    Q_OBJECT

private:
    bool compare(const QList<QString> &list, const QSet<QString> &expectedResult) const noexcept;

private slots:
    void initTestCase();
    void cleanupTestCase();

    void titleSuggestions();
    void ingredientSuggestions();

private:
    const QString mDriver{"QSQLITE"};
    const QString mConnectionName{"testDatabase"};
    const QString mPath{"testDatabase.db"};

    QList<Recipe*> mRecipes {
        new Recipe{mConnectionName, -1, "", "", 0, 0, 0, "", QList<QSharedPointer<Recipe::Ingredient>>()},
        new Recipe{mConnectionName, -1, "", "a", 0, 0, 0, "", QList<QSharedPointer<Recipe::Ingredient>>()},
        new Recipe{mConnectionName, -1, "", "a", 0, 0, 0, "", QList<QSharedPointer<Recipe::Ingredient>>()},
        new Recipe{mConnectionName, -1, "", "ab", 0, 0, 0, "", QList<QSharedPointer<Recipe::Ingredient>>()},
        new Recipe{mConnectionName, -1, "", "abc", 0, 0, 0, "", QList<QSharedPointer<Recipe::Ingredient>>()},
        new Recipe{mConnectionName, -1, "", "abcd", 0, 0, 0, "", QList<QSharedPointer<Recipe::Ingredient>>(
                        {
                            QSharedPointer<Recipe::Ingredient>(new Recipe::Ingredient{"", ""}),
                            QSharedPointer<Recipe::Ingredient>(new Recipe::Ingredient{"a", ""}),
                            QSharedPointer<Recipe::Ingredient>(new Recipe::Ingredient{"a", ""}),
                            QSharedPointer<Recipe::Ingredient>(new Recipe::Ingredient{"ab", ""}),
                            QSharedPointer<Recipe::Ingredient>(new Recipe::Ingredient{"abc", ""}),
                            QSharedPointer<Recipe::Ingredient>(new Recipe::Ingredient{"abcd", ""})
                        })}
    };

    QScopedPointer<DbManager> db;
};

bool TestAutocomplete::compare(const QList<QString> &list, const QSet<QString> &expectedResult) const noexcept
{
    for (int i = 0; i < list.count(); i++) {
        if (!expectedResult.contains(list.at(i)))
            return false;
    }
    return true;
}

void TestAutocomplete::initTestCase()
{
    db.reset(new DbManager{mDriver, mConnectionName, mPath});
    QVERIFY(db->isOpen());
    QVERIFY(db->createTables());

    for (const auto &r : mRecipes)
        QVERIFY(r->addRecipe());

}

void TestAutocomplete::cleanupTestCase()
{
    db->close();
    QVERIFY(QFile::remove(mPath));
}

void TestAutocomplete::titleSuggestions()
{
    QScopedPointer<Autocomplete> autocomplete{new Autocomplete(mConnectionName)};

    {
        autocomplete->suggestions(autocomplete->Title, "");
        const QSet<QString> expectedResult{mRecipes.at(1)->title(),
                    mRecipes.at(3)->title(),
                    mRecipes.at(4)->title(),
                    mRecipes.at(5)->title()};
        QCOMPARE(autocomplete->rowCount(), expectedResult.size());
        QVERIFY(compare(autocomplete->mSuggestions, expectedResult));
    }

    {
        autocomplete->suggestions(autocomplete->Title, "a");
        const QSet<QString> expectedResult{mRecipes.at(1)->title(),
                    mRecipes.at(3)->title(),
                    mRecipes.at(4)->title(),
                    mRecipes.at(5)->title()};
        QCOMPARE(autocomplete->rowCount(), expectedResult.size());
        QVERIFY(compare(autocomplete->mSuggestions, expectedResult));
    }

    {
        autocomplete->suggestions(autocomplete->Title, "b");
        const QSet<QString> expectedResult{mRecipes.at(3)->title(),
                    mRecipes.at(4)->title(),
                    mRecipes.at(5)->title()};
        QCOMPARE(autocomplete->rowCount(), expectedResult.size());
        QVERIFY(compare(autocomplete->mSuggestions, expectedResult));
    }
}

void TestAutocomplete::ingredientSuggestions()
{
    QScopedPointer<Autocomplete> autocomplete{new Autocomplete(mConnectionName)};

    {
        autocomplete->suggestions(autocomplete->Ingredient, "");
        const QSet<QString> expectedResult{mRecipes.at(1)->title(),
                    mRecipes.at(3)->title(),
                    mRecipes.at(4)->title(),
                    mRecipes.at(5)->title()};
        QCOMPARE(autocomplete->rowCount(), expectedResult.size());
        QVERIFY(compare(autocomplete->mSuggestions, expectedResult));
    }

    {
        autocomplete->suggestions(autocomplete->Ingredient, "a");
        const QSet<QString> expectedResult{mRecipes.at(1)->title(),
                    mRecipes.at(3)->title(),
                    mRecipes.at(4)->title(),
                    mRecipes.at(5)->title()};
        QCOMPARE(autocomplete->rowCount(), expectedResult.size());
        QVERIFY(compare(autocomplete->mSuggestions, expectedResult));
    }

    {
        autocomplete->suggestions(autocomplete->Ingredient, "b");
        const QSet<QString> expectedResult{mRecipes.at(3)->title(),
                    mRecipes.at(4)->title(),
                    mRecipes.at(5)->title()};
        QCOMPARE(autocomplete->rowCount(), expectedResult.size());
        QVERIFY(compare(autocomplete->mSuggestions, expectedResult));
    }
}

QTEST_MAIN(TestAutocomplete)
#include "test_autocomplete.moc"
