#include "recipe.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QQmlEngine>

Recipe::Recipe(QObject *parent) : QAbstractListModel(parent)
{}

Recipe::~Recipe()
{
    removeAllIngredients();
}

Recipe::Recipe(int recipeId,
               const QString &pathImage,
               const QString &title,
               int preparationTime,
               int cookingTime,
               int yield,
               const QString &instructions,
               const QList<Recipe::Ingredient*> &ingredientsList,
               QObject *parent
               ) : QAbstractListModel(parent),
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

//    const Ingredient *ingredient = mIngredientsList.at(row);
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

const QString Recipe::name(int index) const
{
    if (index >= 0 && index < mIngredientsList.size())
        return mIngredientsList.at(index)->name;

    return "";
}

void Recipe::setNameAt(int index, const QString &newName)
{
    if (not mIngredientsList.isEmpty() && index < mIngredientsList.size() and mIngredientsList[index]->name != newName)
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
    if (not mIngredientsList.isEmpty() && index < mIngredientsList.size() and mIngredientsList[index]->quantity != newQuantity)
        mIngredientsList[index]->quantity = newQuantity;
}

void Recipe::appendIngredient(const QString &newName, const QString &newQuantity)
{
    beginInsertRows(QModelIndex(), mIngredientsList.count(), mIngredientsList.count());
    mIngredientsList.append(new Ingredient{newName, newQuantity});
    endInsertRows();
}

void Recipe::removeIngredientAt(int index)
{
    if (index < mIngredientsList.count()) {
        beginRemoveRows(QModelIndex(), index, index);
        delete mIngredientsList.at(index);
        mIngredientsList.removeAt(index);
        endRemoveRows();
    }
}

void Recipe::removeAllIngredients()
{
    beginResetModel();
    qDeleteAll(mIngredientsList);
    mIngredientsList.clear();
    endResetModel();
}

void Recipe::getIngredients()
{
    if (!mIngredientsList.empty())
        return;

    QSqlDatabase db = QSqlDatabase::database("cookbook");
//    db.transaction();
    QSqlQuery query(db);
    query.prepare("SELECT ingredientName, quantity "
                  "FROM ingredients NATURAL JOIN recipes_ingredients "
                  "WHERE recipeId = (:recipeId)");
    query.bindValue(":recipeId", recipeId());
    if(!query.exec())
        qDebug() << "SqLite error:" << query.lastError().text() << ", SqLite type code:" << query.lastError().type() << Qt::endl;

    while (query.next()) {
        appendIngredient(query.value(0).toString(), query.value(1).toString());
    }
}

void Recipe::addRecipe()
{
    QSqlDatabase db = QSqlDatabase::database("cookbook");;
//    db.transaction();
    QSqlQuery query(db);
    query.prepare("INSERT INTO recipes (title, pathImage, preparationTime, cookingTime, yield, instructions)"
                  "VALUES (:title, :pathImage, :preparationTime, :cookingTime, :yield, :instructions)");
    query.bindValue(":title", mTitle);
    query.bindValue(":pathImage", mPathImage);
    query.bindValue(":preparationTime", mPreparationTime);
    query.bindValue(":cookingTime", mCookingTime);
    query.bindValue(":yield", mYield);
    query.bindValue(":instructions", mInstructions);
    if (!query.exec())
        qDebug() << "SqLite error:" << query.lastError().text() << ", SqLite type code:" << query.lastError().type() << Qt::endl;

    int recipeId = query.lastInsertId().toInt();

    for (const auto& ingredient : mIngredientsList) {
        int idIngredient = -1;
        query.prepare("SELECT ingredientId FROM ingredients WHERE ingredientName LIKE :name");
        query.bindValue(":name", ingredient->name);
        if (!query.exec()) {
            qDebug() << "SqLite error:" << query.lastError().text() << ", SqLite type code:" << query.lastError().type() << Qt::endl;
        } else if (query.next()) {
            idIngredient = query.value(0).toInt();
        } else {
            query.prepare("INSERT INTO ingredients (ingredientName) VALUES (:ingredientName)");
            query.bindValue(":ingredientName", ingredient->name);
            if (!query.exec()) {
               qDebug() << "SqLite error:" << query.lastError().text() << ", SqLite type code:" << query.lastError().type() << Qt::endl;
            } else {
                idIngredient = query.lastInsertId().toInt();
            }
        }

        query.prepare("INSERT INTO recipes_ingredients (recipeId, ingredientId, quantity)"
                      "VALUES (:recipeId, :ingredientId, :quantity)");
        query.bindValue(":recipeId", recipeId);
        query.bindValue(":ingredientId", idIngredient);
        query.bindValue(":quantity", ingredient->quantity);
        if (!query.exec())
            qDebug() << "SqLite error:" << query.lastError().text() << ", SqLite type code:" << query.lastError().type() << Qt::endl;
    }

//    db.commit();
}

void Recipe::updateRecipe()
{
    QSqlQuery query(QSqlDatabase::database("cookbook"));
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
    if (!query.exec())
        qDebug() << "SqLite error:" << query.lastError().text() << ", SqLite type code:" << query.lastError().type() << Qt::endl;

    query.prepare("DELETE FROM recipes_ingredients WHERE recipeId = :recipeId");
    query.bindValue(":recipeId", mRecipeId);
    if (!query.exec())
        qDebug() << "SqLite error:" << query.lastError().text() << ", SqLite type code:" << query.lastError().type() << Qt::endl;

    for (const auto& ingredient : mIngredientsList) {
        int idIngredient = -1;
        query.prepare("SELECT ingredientId FROM ingredients WHERE ingredientName LIKE :name");
        query.bindValue(":name", ingredient->name);
        if (!query.exec()) {
            qDebug() << "SqLite error:" << query.lastError().text() << ", SqLite type code:" << query.lastError().type() << Qt::endl;
        } else if (query.next()) {
            idIngredient = query.value(0).toInt();
        } else {
            query.prepare("INSERT INTO ingredients (ingredientName) VALUES (:ingredientName)");
            query.bindValue(":ingredientName", ingredient->name);
            if (!query.exec()) {
               qDebug() << "SqLite error:" << query.lastError().text() << ", SqLite type code:" << query.lastError().type() << Qt::endl;
            } else {
                idIngredient = query.lastInsertId().toInt();
            }
        }

        query.prepare("INSERT INTO recipes_ingredients (recipeId, ingredientId, quantity)"
                      "VALUES (:recipeId, :ingredientId, :quantity)");
        query.bindValue(":recipeId", mRecipeId);
        query.bindValue(":ingredientId", idIngredient);
        query.bindValue(":quantity", ingredient->quantity);
        if (!query.exec())
            qDebug() << "SqLite error:" << query.lastError().text() << ", SqLite type code:" << query.lastError().type() << Qt::endl;
    }
}

bool Recipe::deleteRecipe()
{
    QSqlQuery query(QSqlDatabase::database("cookbook"));
    query.prepare("DELETE FROM recipes WHERE recipeid = :recipeId");
    query.bindValue(":recipeId", mRecipeId);
    if (!query.exec()) {
        qDebug() << "SqLite error:" << query.lastError().text() << ", SqLite type code:" << query.lastError().type() << Qt::endl;
        return false;
    }

    return true;
}

Recipe *Recipe::clone()
{
    auto ingrList = QList<Ingredient*>();
    for (const auto &x : mIngredientsList)
        ingrList.append(new Ingredient{x->name, x->quantity});

    Recipe * r = new Recipe(recipeId(),
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
