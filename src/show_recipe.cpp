#include "show_recipe.h"

ShowRecipe::ShowRecipe(QObject *parent)
{
    Q_UNUSED(parent)
}

ShowRecipe::~ShowRecipe()
{
}

int ShowRecipe::rowCount(const QModelIndex& parent) const
{
    if (parent.isValid())
        return 0;

    return mRecipes.count();
}

QVariant ShowRecipe::data( const QModelIndex& index, int role) const
{
    if ( !index.isValid() )
        return QVariant();

    const Recipe &recipe = mRecipes.at(index.row());
    switch (role) {
    case RecipeIdRole:
        return recipe.recipeId;
    case PathImageRole:
        return recipe.pathImage;
    case RecipeTitleRole:
        return recipe.recipeTitle;
    case PreparationTimeRole:
        return recipe.preparationTime;
    case CookingTimeRole:
        return recipe.cookingTime;
    case YieldRole:
        return recipe.yield;
    case InstructionsRole:
        return recipe.instructions;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> ShowRecipe::roleNames() const
{
    static QHash<int, QByteArray> names {
        {RecipeIdRole, "recipeId"},
        {PathImageRole, "pathImage"},
        {RecipeTitleRole, "recipeTitle"},
        {PreparationTimeRole, "preparationTime"},
        {CookingTimeRole, "cookingTime"},
        {YieldRole, "yield"},
        {InstructionsRole, "instructions"}
    };
    return names;
}

void ShowRecipe::appendRecipe(Recipe recipe)
{
    beginInsertRows(QModelIndex(), mRecipes.size(), mRecipes.size());
    mRecipes.insert(mRecipes.size(), recipe);
    endInsertRows();
}

void ShowRecipe::removeAllRecipes()
{
    beginResetModel();
    mRecipes.clear();
    endResetModel();
}
