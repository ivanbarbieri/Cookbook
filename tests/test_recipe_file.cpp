#include "../src/recipe.h"
#include "../src/db_manager.h"

#include <QTest>
#include <QDir>
#include <QFile>
#include <QSqlQuery>

class TestRecipeFile : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void cleanupTestCase();
    void init();
    void cleanup();
    void copyImage();
    void deleteImage();
    void copyAndDeleteImage();

private:
    const QString dirImages{"images"};
    const QString mDriver{"QSQLITE"};
    const QString mConnectionName{"testDatabase"};
    const QString mPath{"testDatabase.db"};
    QScopedPointer<DbManager> db;
};

void TestRecipeFile::init()
{
    QFile file("testImage.jpg");
    file.open(QIODevice::WriteOnly);
    file.close();
    QDir dir{QDir::current()};
    QVERIFY2(dir.mkpath(dirImages), QString("Error create directory /" + dirImages + " in " + dir.path()).toLocal8Bit());
}

void TestRecipeFile::cleanup()
{
    QDir dir{QDir::current()};
    if (dir.cd(dirImages))
       dir.removeRecursively();
}

void TestRecipeFile::initTestCase()
{
    db.reset(new DbManager{mDriver, mConnectionName, mPath});
    QVERIFY(db->isOpen());
    QVERIFY(db->createTables());
    QVERIFY(db->foreignKeys(true));
    QVERIFY(db->createTriggers());
}

void TestRecipeFile::cleanupTestCase()
{
    QDir dir{QDir::current()};
    dir.remove("testImage.jpg");

    db->close();
    QVERIFY(QFile::remove(mPath));
}

void TestRecipeFile::copyImage()
{
    Recipe rSample{mConnectionName, -1, "path/image", "0 ingr", 0, 0, 0, "instructions",
                QList<QSharedPointer<Recipe::Ingredient>>()};
    QVERIFY(rSample.addRecipe());
    Recipe r;
    r.setConnectionName(mConnectionName);
    r.setRecipeId(rSample.recipeId());
    r.setPathImage("file:testImage.jpg");

    QDir dir{QDir::current()};
    dir.cd(dirImages);

    QVERIFY(r.copyImage());
    QVERIFY(dir.exists("testImage.jpg"));
    QVERIFY(r.copyImage());
    QVERIFY(dir.exists("testImage (1).jpg"));
    QVERIFY(r.copyImage());
    QVERIFY(dir.exists("testImage (2).jpg"));
    QVERIFY(r.copyImage());
    QVERIFY(dir.exists("testImage (3).jpg"));
}

void TestRecipeFile::deleteImage()
{
    Recipe r;
    QVERIFY(r.deleteImage("file:testImage.jpg"));
}

void TestRecipeFile::copyAndDeleteImage()
{
    Recipe rSample{mConnectionName, -1, "path/image", "0 ingr", 0, 0, 0, "instructions",
                QList<QSharedPointer<Recipe::Ingredient>>()};
    QVERIFY(rSample.addRecipe());
    Recipe r;
    r.setConnectionName(mConnectionName);
    r.setRecipeId(rSample.recipeId());
    r.setPathImage("file:testImage.jpg");

    QDir dir{QDir::current()};
    dir.cd(dirImages);

    QVERIFY(r.copyImage());
    QVERIFY(dir.exists("testImage.jpg"));
    r.setPathImage("file:testImage.jpg");
    QVERIFY(r.copyImage());
    QVERIFY(dir.exists("testImage (1).jpg"));
    r.setPathImage("file:testImage.jpg");
    QVERIFY(r.copyImage());
    QVERIFY(r.deleteImage("file:" + dirImages + "/testImage (1).jpg"));
    r.setPathImage("file:testImage.jpg");
    QVERIFY(r.copyImage());
    QVERIFY(dir.exists("testImage (1).jpg"));
}

QTEST_MAIN(TestRecipeFile)
#include "test_recipe_file.moc"
