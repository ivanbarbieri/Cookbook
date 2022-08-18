#ifndef SEARCHRECIPE_H
#define SEARCHRECIPE_H

#include "recipes_list.h"

#include <QStringListModel>

class SearchRecipe : public QStringListModel {
    Q_OBJECT
    QML_NAMED_ELEMENT(CppSearchRecipe)

public:
    enum Roles {
        IngredientRole = Qt::UserRole
    };

    explicit SearchRecipe(RecipesList *rl, QObject *parent = nullptr);

    int rowCount(const QModelIndex& parent) const override;
    QVariant data( const QModelIndex& index, int role = Qt::DisplayRole ) const override;

public slots:
    void setIngredientAt(int index, const QString &ingredient);
    void appendIngredient();
    void removeIngredientAt(int index);
    void search(const QString &title);

private:
    RecipesList *recipesList;
    QList<QString> mIngredients;
};

#endif // SEARCHRECIPE_H
