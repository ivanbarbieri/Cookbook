#ifndef SEARCH_RECIPE_H
#define SEARCH_RECIPE_H
#include "show_recipe.h"

#include <QAbstractListModel>
#include <QSqlQuery>
#include <QSqlError>

class SearchRecipe : public QAbstractListModel {
    Q_OBJECT

public:
    explicit SearchRecipe(QObject *parent = nullptr, ShowRecipe *sr = nullptr);
    ~SearchRecipe();
    int rowCount(const QModelIndex& parent) const override;
    QVariant data( const QModelIndex& index, int role = Qt::DisplayRole ) const override;
    QHash<int, QByteArray> roleNames() const override;

public slots:
    void setIngredientAt(int index, const QString &ingredient);
    void appendIngredient();
    void removeIngredientAt(int index);
    void search(const QString &recipeTitle);

private:
    ShowRecipe *showRecipe;
    QVector<QString> mIngredients;
};
#endif // SEARCH_RECIPE_H
