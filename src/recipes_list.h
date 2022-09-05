#ifndef RECIPESLIST_H
#define RECIPESLIST_H

#include "recipe.h"

#include <QAbstractListModel>
#include <QtQml/qqml.h>

class RecipesList : public QAbstractListModel
{
    Q_OBJECT
    QML_NAMED_ELEMENT(CppRecipesList)

public:
    enum Roles {
        RecipeRole = Qt::UserRole
    };

    explicit RecipesList(const QString &connectionName, QObject *parent = nullptr);
    ~RecipesList();

    // QAbstractItemModel interface
    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

public slots:
    QVariant recipe(int index) const;
    void appendRecipe(Recipe *r);
    void removeRecipe(int index);
    void removeAllRecipes();
    bool isEmpty();

signals:
    void rowInserted();
    void rowRemoved();

public:
    const QString mConnectionName;

private:
    QList<QSharedPointer<Recipe>> mRecipes;
    const QHash<int, QByteArray> m_roles;
};

QML_DECLARE_TYPE(QSharedPointer<Recipe>)

#endif // RECIPESLIST_H
