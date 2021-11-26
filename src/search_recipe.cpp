#include "search_recipe.h"

SearchRecipe::SearchRecipe(QObject *parent, ShowRecipe *sr) : QAbstractListModel(parent)
{
    showRecipe = sr;
}

SearchRecipe::~SearchRecipe()
{
}

int SearchRecipe::rowCount(const QModelIndex& parent) const
{
    if (parent.isValid())
        return 0;

    return mIngredients.count();
}

QVariant SearchRecipe::data( const QModelIndex& index, int role) const
{
    Q_UNUSED(role)
    if (!index.isValid())
        return QVariant();

    return mIngredients.at(index.row());
}

QHash<int, QByteArray> SearchRecipe::roleNames() const
{
    static QHash<int, QByteArray> names {};
    return names;
}

void SearchRecipe::setIngredientAt(int index, const QString &ingredient)
{
    if (index < mIngredients.size())
        mIngredients[index] = ingredient;
}

void SearchRecipe::appendIngredient()
{
    beginInsertRows(QModelIndex(), mIngredients.size(), mIngredients.size());
    mIngredients.insert(mIngredients.size(), "");
    endInsertRows();
}

void SearchRecipe::removeIngredientAt(int index)
{
    if (index < mIngredients.size()) {
        beginRemoveRows(QModelIndex(), index, index);
        mIngredients.removeAt(index);
        endRemoveRows();
    }
}

void SearchRecipe::search(const QString &recipeTitle)
{
    QSqlDatabase db = QSqlDatabase::database("cookbook");
    QSqlQuery query(db);
    QString strQuery;
    showRecipe->removeAllRecipes();

    strQuery.append("SELECT recipeId, pathImage, recipeTitle, preparationTime, cookingTime, yield, instructions "
                    "FROM recipes "
                    "WHERE recipeTitle LIKE ? ");
    if (not mIngredients.isEmpty()) {
        strQuery.append("AND recipeId IN (SELECT recipeId "
                        "FROM recipes_ingredients NATURAL JOIN ingredients "
                        "WHERE ");
        for (int i = 0; i < mIngredients.size(); i++) {
            strQuery.append("ingredientName LIKE ? ");
            if (i + 1 < mIngredients.size())
                strQuery.append(" OR ");
        }
        strQuery.append(" GROUP BY recipeId HAVING COUNT(*) = " + QString::number(mIngredients.size()) + ") ");
    }
    strQuery.append(" ORDER BY recipeTitle");

    query.prepare(strQuery);
    query.addBindValue("%" + recipeTitle.simplified() + "%");
    for (int i = 0; i < mIngredients.size(); i++)
        query.addBindValue("%" + mIngredients[i].simplified() + "%");
    query.exec();
    if(!query.exec())
        qDebug() << "SqLite error:" << query.lastError().text() << ", SqLite type code:" << query.lastError().type() << Qt::endl;

    while (query.next()) {
        showRecipe->appendRecipe({query.value(0).toInt(),
                                  query.value(1).toString(),
                                  query.value(2).toString(),
                                  query.value(3).toString(),
                                  query.value(4).toString(),
                                  query.value(5).toString(),
                                  query.value(6).toString()
                                 });
    }
}
