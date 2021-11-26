#ifndef SHOW_RECIPE_H
#define SHOW_RECIPE_H
#include <QAbstractListModel>

class ShowRecipe : public QAbstractListModel {
    Q_OBJECT

public:
    struct Recipe {
        int recipeId;
        QString pathImage;
        QString recipeTitle;
        QString preparationTime;
        QString cookingTime;
        QString yield;
        QString instructions;
    };

    enum RecipeRoles {
        RecipeIdRole = Qt::UserRole,
        PathImageRole,
        RecipeTitleRole,
        PreparationTimeRole,
        CookingTimeRole,
        YieldRole,
        InstructionsRole
    };

    explicit ShowRecipe(QObject *parent = nullptr);
    ~ShowRecipe();
    int rowCount(const QModelIndex& parent) const override;
    QVariant data( const QModelIndex& index, int role = Qt::DisplayRole ) const override;
    QHash<int, QByteArray> roleNames() const override;
    void removeAllRecipes();
public slots:
    void appendRecipe(Recipe recipe);

private:
    QVector<Recipe> mRecipes;
};
#endif // SHOW_RECIPE_H
