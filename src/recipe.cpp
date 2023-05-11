#include "db_manager.h"
#include "recipe.h"

#include <QSqlDriver>
#include <QSqlQuery>
#include <QQmlEngine>
#include <QSharedPointer>

#include <QDir>
#include <QFileInfo>
#include <QUrl>
#include <QRegularExpression>

class QFile;

Recipe::Recipe(const QString &connectionName,
               int recipeId,
               const QString &pathImage,
               const QString &title,
               int preparationTime,
               int cookingTime,
               int yield,
               const QString &instructions,
               const QList<QSharedPointer<Recipe::Ingredient>> &ingredientsList,
               QObject *parent
               ) : QAbstractListModel(parent),
    mConnectionName(connectionName),
    mRecipeId(recipeId),
    mPathImage(pathImage),
    mTitle(title),
    mPreparationTime(preparationTime),
    mCookingTime(cookingTime),
    mYield(yield),
    mInstructions(instructions),
    mIngredientsList(ingredientsList)
{}

int Recipe::rowCount( const QModelIndex& parent) const
{
    Q_UNUSED(parent)
    return mIngredientsList.count();
}

QVariant Recipe::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    int row = index.row();
    if (row < 0 || row >= mIngredientsList.count())
        return QVariant();

    switch (role) {
    case NameRole:
        return mIngredientsList.at(row)->name;
    case QuantityRole:
        return mIngredientsList.at(row)->quantity;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> Recipe::roleNames() const
{
    static QHash<int, QByteArray> names {
        {NameRole, "name"},
        {QuantityRole, "quantity"}
    };
    return names;
}

int Recipe::recipeId() const
{
    return mRecipeId;
}

void Recipe::setRecipeId(int newRecipeId)
{
    if (mRecipeId == newRecipeId)
        return;

    mRecipeId = newRecipeId;
    emit recipeIdChanged();
}

const QString Recipe::pathImage() const
{
    return mPathImage;
}

void Recipe::setPathImage(const QString &newPathImage)
{
    if (mPathImage == newPathImage)
        return;

    mPathImage = newPathImage;
    emit pathImageChanged();
}

const QString Recipe::title() const
{
    return mTitle;
}

void Recipe::setTitle(const QString &newTitle)
{
    if (mTitle == newTitle)
        return;

    mTitle = newTitle;
    emit titleChanged();
}

int Recipe::preparationTime() const
{
    return mPreparationTime;
}

void Recipe::setPreparationTime(const int newPreparationTime)
{
    if (mPreparationTime == newPreparationTime)
        return;

    mPreparationTime = newPreparationTime;
    emit preparationTimeChanged();
}

int Recipe::cookingTime() const
{
    return mCookingTime;
}

void Recipe::setCookingTime(const int newCookingTime)
{
    if (mCookingTime == newCookingTime)
        return;

    mCookingTime = newCookingTime;
    emit cookingTimeChanged();
}

int Recipe::yield() const
{
    return mYield;
}

void Recipe::setYield(const int newYield)
{
    if (mYield == newYield)
        return;

    mYield = newYield;
    emit yieldChanged();
}

const QString Recipe::instructions() const
{
    return mInstructions;
}

void Recipe::setInstructions(const QString &newInstructions)
{
    if (mInstructions == newInstructions)
        return;

    mInstructions = newInstructions;
    emit instructionsChanged();
}

void Recipe::setIngredientAt(int index, const QString &newName, const QString &newQuantity)
{
        setNameAt(index, newName);
        setQuantityAt(index, newQuantity);
}

const QList<QSharedPointer<Recipe::Ingredient>> Recipe::ingredientsList() const
{
    return mIngredientsList;
}

const QString Recipe::name(int index) const
{
    if (index >= 0 && index < mIngredientsList.size())
        return mIngredientsList.at(index)->name;

    return "";
}

void Recipe::setNameAt(int index, const QString &newName)
{
    if (not mIngredientsList.isEmpty() && index < mIngredientsList.size() && mIngredientsList[index]->name != newName)
        mIngredientsList[index]->name = newName;
}

const QString Recipe::quantity(int index) const
{
    if (index >= 0 && index < mIngredientsList.size())
        return mIngredientsList.at(index)->quantity;

    return "";
}

void Recipe::setQuantityAt(int index, const QString &newQuantity)
{
    if (not mIngredientsList.isEmpty() && index < mIngredientsList.size() && mIngredientsList[index]->quantity != newQuantity)
        mIngredientsList[index]->quantity = newQuantity;
}

void Recipe::appendIngredient(const QString &newName, const QString &newQuantity)
{
    beginInsertRows(QModelIndex(), mIngredientsList.count(), mIngredientsList.count());
    mIngredientsList.append(QSharedPointer<Recipe::Ingredient>(new Recipe::Ingredient{newName, newQuantity}));
    endInsertRows();
}

void Recipe::removeIngredientAt(int index)
{
    if (index < mIngredientsList.count()) {
        beginRemoveRows(QModelIndex(), index, index);
        mIngredientsList.removeAt(index);
        endRemoveRows();
    }
}

void Recipe::removeAllIngredients()
{
    beginResetModel();
    mIngredientsList.clear();
    endResetModel();
}

void Recipe::getIngredients()
{
    if (!mIngredientsList.empty())
        return;

    QSqlDatabase db = QSqlDatabase::database(mConnectionName);
    QSqlQuery query(db);
    query.prepare("SELECT ingredientName, quantity "
                  "FROM ingredients NATURAL JOIN recipes_ingredients "
                  "WHERE recipeId = (:recipeId)");
    query.bindValue(":recipeId", recipeId());
    if(!query.exec())
        qWarning() << DbManager::errorMessage(query);

    while (query.next()) {
        appendIngredient(query.value(0).toString(), query.value(1).toString());
    }
}

void Recipe::setConnectionName(const QString &newConnectionName)
{
    if (mConnectionName == newConnectionName)
        return;

    mConnectionName = newConnectionName;
}

bool Recipe::addRecipe()
{
    QSqlDatabase db = QSqlDatabase::database(mConnectionName);
    if (!db.transaction()) {
        if (!db.driver()->hasFeature(QSqlDriver::Transactions))
            qWarning("The driver doesn't support transactions");

        return false;
    }

    QSqlQuery query(db);
    query.prepare("INSERT INTO recipes (title, pathImage, preparationTime, cookingTime, yield, instructions)"
                  "VALUES (:title, :pathImage, :preparationTime, :cookingTime, :yield, :instructions)");
    query.bindValue(":title", mTitle);
    query.bindValue(":pathImage", mPathImage);
    query.bindValue(":preparationTime", mPreparationTime);
    query.bindValue(":cookingTime", mCookingTime);
    query.bindValue(":yield", mYield);
    query.bindValue(":instructions", mInstructions);
    if (!query.exec()) {
        qWarning() << DbManager::errorMessage(query);
        if (!db.rollback())
            qWarning() << DbManager::errorMessage(query);

        return false;
    }

    mRecipeId = query.lastInsertId().toInt();

    for (const auto& ingredient : mIngredientsList) {
        int idIngredient = -1;
        query.prepare("SELECT ingredientId FROM ingredients WHERE ingredientName LIKE :name");
        query.bindValue(":name", ingredient->name);
        if (!query.exec()) {
            qWarning() << DbManager::errorMessage(query);
            if (!db.rollback())
                qWarning() << DbManager::errorMessage(query);

            return false;
        } else if (query.next()) {
            idIngredient = query.value(0).toInt();
        } else {
            query.prepare("INSERT INTO ingredients (ingredientName) VALUES (:ingredientName)");
            query.bindValue(":ingredientName", ingredient->name);
            if (!query.exec()) {
               qWarning() << DbManager::errorMessage(query);
               if (!db.rollback())
                   qWarning() << DbManager::errorMessage(query);

               return false;
            } else {
                idIngredient = query.lastInsertId().toInt();
            }
        }

        query.prepare("INSERT INTO recipes_ingredients (recipeId, ingredientId, quantity)"
                      "VALUES (:recipeId, :ingredientId, :quantity)");
        query.bindValue(":recipeId", mRecipeId);
        query.bindValue(":ingredientId", idIngredient);
        query.bindValue(":quantity", ingredient->quantity);
        if (!query.exec()) {
            qWarning() << DbManager::errorMessage(query);
            if (!db.rollback())
                qWarning() << DbManager::errorMessage(query);

            return false;
        }
    }

    if (!db.commit()) {
        qWarning() << DbManager::errorMessage(query);
        return false;
    }
    return true;
}

bool Recipe::updateRecipe()
{
    QSqlDatabase db{QSqlDatabase::database(mConnectionName)};
    if (!db.transaction()) {
        if (!db.driver()->hasFeature(QSqlDriver::Transactions))
            qWarning("The driver doesn't support transactions");

        return false;
    }

    QSqlQuery query(db);
    query.prepare("UPDATE recipes SET"
                  " title = :title,"
                  " pathImage = :pathImage,"
                  " preparationTime = :preparationTime,"
                  " cookingTime = :cookingTime,"
                  " yield = :yield,"
                  " instructions = :instructions"
                  " WHERE recipeId = :recipeId");
    query.bindValue(":title", mTitle);
    query.bindValue(":pathImage", mPathImage);
    query.bindValue(":preparationTime", mPreparationTime);
    query.bindValue(":cookingTime", mCookingTime);
    query.bindValue(":yield", mYield);
    query.bindValue(":instructions", mInstructions);
    query.bindValue(":recipeId", mRecipeId);
    if (!query.exec()) {
        qWarning() << DbManager::errorMessage(query);
        if (!db.rollback())
            qWarning() << DbManager::errorMessage(query);

        return false;
    } else if (query.numRowsAffected() <= 0) {
        return false;
    }

    query.prepare("DELETE FROM recipes_ingredients WHERE recipeId = :recipeId");
    query.bindValue(":recipeId", mRecipeId);
    if (!query.exec()) {
        qWarning() << DbManager::errorMessage(query);
        if (!db.rollback())
            qWarning() << DbManager::errorMessage(query);

        return false;
    }

    for (const auto& ingredient : mIngredientsList) {
        int idIngredient{-1};
        query.prepare("SELECT ingredientId FROM ingredients WHERE ingredientName LIKE :name");
        query.bindValue(":name", ingredient->name);
        if (!query.exec()) {
            qWarning() << DbManager::errorMessage(query);
            if (!db.rollback())
                qWarning() << DbManager::errorMessage(query);

            return false;
        } else if (query.next()) {
            idIngredient = query.value(0).toInt();
        } else {
            query.prepare("INSERT INTO ingredients (ingredientName) VALUES (:ingredientName)");
            query.bindValue(":ingredientName", ingredient->name);
            if (!query.exec()) {
               qWarning() << DbManager::errorMessage(query);
               if (!db.rollback())
                   qWarning() << DbManager::errorMessage(query);

                return false;
            } else {
                idIngredient = query.lastInsertId().toInt();
            }
        }

        query.prepare("INSERT INTO recipes_ingredients (recipeId, ingredientId, quantity)"
                      "VALUES (:recipeId, :ingredientId, :quantity)");
        query.bindValue(":recipeId", mRecipeId);
        query.bindValue(":ingredientId", idIngredient);
        query.bindValue(":quantity", ingredient->quantity);
        if (!query.exec()) {
            qWarning() << DbManager::errorMessage(query);
            if (!db.rollback())
                qWarning() << DbManager::errorMessage(query);

            return false;
        }
    }

    if (!db.commit()) {
        qWarning() << DbManager::errorMessage(query);
        return false;
    }
    return true;
}

bool Recipe::deleteRecipe()
{
    QSqlQuery query(QSqlDatabase::database(mConnectionName));
    query.prepare("DELETE FROM recipes WHERE recipeid = :recipeId");
    query.bindValue(":recipeId", mRecipeId);
    if (!query.exec()) {
        qWarning() << DbManager::errorMessage(query);
        return false;
    }
    return true;
}

Recipe *Recipe::clone()
{
    auto ingrList{QList<QSharedPointer<Recipe::Ingredient>>()};
    for (const auto &x : mIngredientsList)
        ingrList.append(QSharedPointer<Recipe::Ingredient>(new Recipe::Ingredient{x->name, x->quantity}));

    Recipe *r = new Recipe(mConnectionName,
                        recipeId(),
                        pathImage(),
                        title(),
                        preparationTime(),
                        cookingTime(),
                        yield(),
                        instructions(),
                        ingrList);
     QQmlEngine::setObjectOwnership(r, QQmlEngine::CppOwnership);
     return r;
}

bool Recipe::isEmpty()
{
    return mIngredientsList.isEmpty();
}

bool Recipe::copyImage()
{
    if (mPathImage.isEmpty())
        return false;

    static QRegularExpression re{" \\(([1-9]\\d*)\\)$"};
    const QString dirImages{"images"};

    QUrl url(mPathImage);
    QDir dir{QDir::current()};
    if (!dir.mkpath(dirImages))
        return false;

    if (!dir.cd(dirImages))
        return false;

    QSqlDatabase db{QSqlDatabase::database(mConnectionName)};
    if (!db.transaction()) {
        if (!db.driver()->hasFeature(QSqlDriver::Transactions))
            qWarning("The driver doesn't support transactions");

        return false;
    }


    QFileInfo image{url.fileName()};
    QString name{image.baseName()};

    if(QFile::exists(dir.filePath(image.fileName()))) {
        do {
            QRegularExpressionMatch match;
            if (name.lastIndexOf(QRegularExpression(re), -1, &match) != -1) {
                int num{match.captured(1).toInt() + 1};
                qsizetype startOffset{match.capturedStart(1)};

                QString strNum;
                strNum.setNum(num);
                name.replace(startOffset, strNum.length() + 1, strNum + ")");
            } else {
                name.append(" (1)");
            }
        } while (QFile::exists(dir.filePath(name + "." + image.completeSuffix())));
    }

    name.append("." + image.completeSuffix());
    name = dir.filePath(name);

    QSqlQuery query(db);
    query.prepare("UPDATE recipes SET"
                  " pathImage = :pathImage"
                  " WHERE recipeId = :recipeId");
    query.bindValue(":pathImage", QUrl::fromLocalFile(dir.filePath(name)).toString());
    query.bindValue(":recipeId", mRecipeId);
    if (!query.exec()) {
        qWarning() << DbManager::errorMessage(query);
        if (!db.rollback())
            qWarning() << DbManager::errorMessage(query);

        return false;
    } else if (query.numRowsAffected() <= 0) {
        return false;
    }

    if (QFile::copy(url.toLocalFile(), dir.filePath(name))) {
        if (!db.commit()) {
            qWarning() << DbManager::errorMessage(query);
            return false;
        }
        setPathImage(QUrl::fromLocalFile(dir.filePath(name)).toString());
        return true;
    }

    if (!db.rollback())
        qWarning() << DbManager::errorMessage(query);

    return false;
}

bool Recipe::deleteImage(const QString &path) const
{
    return QFile::remove(QUrl(path).toLocalFile());
}
