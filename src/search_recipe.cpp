#include "db_manager.h"
#include "search_recipe.h"
#include "recipes_list.h"

#include <QSqlQuery>
#include <QQmlEngine>

SearchRecipe::SearchRecipe(RecipesList *rl, QObject *parent) : QStringListModel(parent)
{
    recipesList = rl;
}

int SearchRecipe::rowCount(const QModelIndex& parent) const
{
    if (parent.isValid())
        return 0;

    return mIngredients.count();
}

QVariant SearchRecipe::data(const QModelIndex& index, int role) const
{
    Q_UNUSED(role)
    if (!index.isValid())
        return QVariant();

    return mIngredients.at(index.row());
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

void SearchRecipe::search(const QString &title)
{
    QSqlDatabase db = QSqlDatabase::database(recipesList->mConnectionName);
    QSqlQuery query(db);
    QString strQuery;

    recipesList->removeAllRecipes();

    strQuery.append("SELECT recipeId, pathImage, title, preparationTime, cookingTime, yield, instructions "
                    "FROM recipes "
                    "WHERE title LIKE ? ");
    if (not mIngredients.isEmpty()) {
        strQuery.append("AND recipeId IN (SELECT recipeId "
                        "FROM recipes_ingredients AS ri "
                        "WHERE EXISTS (SELECT recipeId FROM recipes_ingredients NATURAL JOIN ingredients WHERE ri.recipeId=recipeId AND IngredientName LIKE ? ) ");
        for (int i = 1; i < mIngredients.size(); i++)
            strQuery.append("  AND EXISTS (SELECT recipeId FROM recipes_ingredients NATURAL JOIN ingredients WHERE ri.recipeId=recipeId AND IngredientName LIKE ? ) ");
        strQuery.append(") ");
    }
    strQuery.append(" ORDER BY title");

    query.prepare(strQuery);
    query.addBindValue("%" + title.simplified() + "%");
    for (int i = 0; i < mIngredients.size(); i++)
        query.addBindValue("%" + mIngredients[i].simplified() + "%");
    if(!query.exec())
        qWarning() << DbManager::errorMessage(query);

    while (query.next()) {
        Recipe *r = new Recipe(recipesList->mConnectionName,
                    query.value(0).toInt(),             // recipeId
                    query.value(1).toString(),          // pathImage
                    query.value(2).toString(),          // title
                    query.value(3).toInt(),             // preparationTime
                    query.value(4).toInt(),             // cookingTime
                    query.value(5).toInt(),             // yield
                    query.value(6).toString(),          // instructions
                    QList<Recipe::Ingredient*>());      // (empty) ingredientsList
        QQmlEngine::setObjectOwnership(r, QQmlEngine::CppOwnership);
        recipesList->appendRecipe(r);
    }
}
