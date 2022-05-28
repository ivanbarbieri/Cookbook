#include "recipes_list.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>

RecipesList::RecipesList(QObject *parent) : QAbstractListModel(parent)
{
}

RecipesList::~RecipesList()
{
    removeAllRecipes();
}

int RecipesList::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return mRecipes.count();
}

QVariant RecipesList::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    int row = index.row();
    if (row < 0 || row >= mRecipes.count())
        return QVariant();

    switch (role) {
    case RecipeRole:
        return QVariant::fromValue(mRecipes.at(index.row()));
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> RecipesList::roleNames() const
{
    static QHash<int, QByteArray> names {
        {RecipeRole, "ingredientsList"},
    };
    return names;
}

void RecipesList::appendRecipe(Recipe *r)
{
    beginInsertRows(QModelIndex(), rowCount(), rowCount());
    mRecipes.append(r);
    endInsertRows();
}

void RecipesList::removeRecipe(int index)
{
    if (index < mRecipes.size()) {
        beginRemoveRows(QModelIndex(), index, index);
        delete mRecipes.at(index);
        mRecipes.remove(index);
        endRemoveRows();
    }
}

void RecipesList::removeAllRecipes()
{
    beginResetModel();
    for (const auto &x : mRecipes)
        x->removeAllIngredients();
    qDeleteAll(mRecipes);
    mRecipes.clear();
    endResetModel();
}

QVariant RecipesList::recipe(int index) const
{
    if (index < 0 || index >= rowCount())
        return QModelIndex();
    return QVariant::fromValue(mRecipes.at(index));
}

bool RecipesList::isEmpty()
{
    return mRecipes.isEmpty();
}
