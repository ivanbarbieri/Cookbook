#include "add_recipe.h"

AddRecipe::AddRecipe(QObject *parent) : QAbstractListModel(parent)
{
}

AddRecipe::~AddRecipe()
{
}

int AddRecipe::rowCount( const QModelIndex& parent) const
{
    if (parent.isValid())
        return 0;

    return mIngredients.count();
}

QVariant AddRecipe::data(const QModelIndex &index, int role) const
{
    if ( !index.isValid() )
        return QVariant();

    const Ingredient &ingredient = mIngredients.at(index.row());
    switch (role) {
    case NameRole:
        return ingredient.name;
    case QuantityRole:
        return ingredient.quantity;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> AddRecipe::roleNames() const
{
    static QHash<int, QByteArray> names {
        {NameRole, "name"},
        {QuantityRole, "quantity"}
    };
    return names;
}

void AddRecipe::setNameAt(int index, const QString &name)
{
    if (index < mIngredients.size())
        mIngredients[index].name = name;
}

void AddRecipe::setQuantityAt(int index, const QString &quantity)
{
    if (index < mIngredients.size())
        mIngredients[index].quantity = quantity;
}

void AddRecipe::appendIngredient()
{
    Ingredient ingredient;
    beginInsertRows(QModelIndex(), mIngredients.size(), mIngredients.size());
    mIngredients.insert(mIngredients.size(), ingredient);
    endInsertRows();
}

void AddRecipe::removeIngredientAt(int index)
{
    if (index < mIngredients.size()) {
        beginRemoveRows(QModelIndex(), index, index);
        mIngredients.removeAt(index);
        endRemoveRows();
    }
}

void AddRecipe::removeAllIngredients()
{
    for (int index = 0; index < mIngredients.size(); index++) {
        beginRemoveRows(QModelIndex(), index, index);
        mIngredients.removeAt(index);
        endRemoveRows();
    }
}

void AddRecipe::addRecipe(const QString &pathImage, const QString &recipeTitle,
                                 const QString &preparationTime, const QString &cookingTime,
                                 const QString &yield, const QString &instructions)
{
    QSqlDatabase db = QSqlDatabase::database("cookbook");;
    db.transaction();
    QSqlQuery query(db);
    query.prepare("INSERT INTO recipes (recipeTitle, pathImage, preparationTime, cookingTime, yield, instructions)"
                  "VALUES (:recipeTitle, :pathImage, :preparationTime, :cookingTime, :yield, :instructions)");
    query.bindValue(":recipeTitle", recipeTitle);
    query.bindValue(":pathImage", pathImage);
    query.bindValue(":preparationTime", preparationTime);
    query.bindValue(":cookingTime", cookingTime);
    query.bindValue(":yield", yield);
    query.bindValue(":instructions", instructions);
    if (!query.exec())
         qDebug() << "SqLite error:" << query.lastError().text() << Qt::endl;

    int recipeId = query.lastInsertId().toInt();

    for (const auto& ingredient : mIngredients) {
        int idIngredient = -1;
        query.prepare("SELECT ingredientId FROM ingredients WHERE ingredientName LIKE :name");
        query.bindValue(":name", ingredient.name);
        if (!query.exec()) {
            qDebug() << "SqLite error:" << query.lastError().text() << Qt::endl;
        } else if (query.next()) {
            idIngredient = query.value(0).toInt();
        } else {
            query.prepare("INSERT INTO ingredients (ingredientName) VALUES (:ingredientName)");
            query.bindValue(":ingredientName", ingredient.name);
            if (!query.exec()) {
                qDebug() << "SqLite error:" << query.lastError().text() << Qt::endl;
            } else {
                idIngredient = query.lastInsertId().toInt();
            }
        }

        query.prepare("INSERT INTO recipes_ingredients (recipeId, ingredientId, quantity)"
                      "VALUES (:recipeId, :ingredientId, :quantity)");
        query.bindValue(":recipeId", recipeId);
        query.bindValue(":ingredientId", idIngredient);
        query.bindValue(":quantity", ingredient.quantity);
        if (!query.exec())
            qDebug() << "SqLite error:" << query.lastError().text() << Qt::endl;
    }

    db.commit();
}
