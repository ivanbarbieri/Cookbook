#ifndef ADD_RECIPE_H
#define ADD_RECIPE_H
#include <QAbstractListModel>
#include <QSqlQuery>
#include <QSqlError>

struct Ingredient {
    QString name;
    QString quantity;
};


class AddRecipe : public QAbstractListModel {
    Q_OBJECT

public:
    enum Roles {
        NameRole = Qt::UserRole,
        QuantityRole
    };

    explicit AddRecipe(QObject *parent = nullptr);
    ~AddRecipe();
    int rowCount(const QModelIndex& parent) const override;
    QVariant data( const QModelIndex& index, int role = Qt::DisplayRole ) const override;
    QHash<int, QByteArray> roleNames() const override;

public slots:
    void setNameAt(int index, const QString &name);
    void setQuantityAt(int index, const QString &quantity);
    void appendIngredient();
    void removeIngredientAt(int index);
    void removeAllIngredients();
    void addRecipe(const QString &pathImage, const QString &recipeTitle,
                   const QString &preparationTime, const QString &cookTime,
                   const QString &yield, const QString &instructions);

private:
    QVector<Ingredient> mIngredients;
};
#endif // ADD_RECIPE_H
