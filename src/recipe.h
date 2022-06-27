#ifndef RECIPE_H
#define RECIPE_H

#include <QAbstractListModel>
#include <QtQml/qqml.h>



class Recipe : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int recipeId READ recipeId WRITE setRecipeId NOTIFY recipeIdChanged)
    Q_PROPERTY(QString pathImage READ pathImage WRITE setPathImage NOTIFY pathImageChanged)
    Q_PROPERTY(QString title READ title WRITE setTitle NOTIFY titleChanged)
    Q_PROPERTY(int preparationTime READ preparationTime WRITE setPreparationTime NOTIFY preparationTimeChanged)
    Q_PROPERTY(int cookingTime READ cookingTime WRITE setCookingTime NOTIFY cookingTimeChanged)
    Q_PROPERTY(int yield READ yield WRITE setYield NOTIFY yieldChanged)
    Q_PROPERTY(QString instructions READ instructions WRITE setInstructions NOTIFY instructionsChanged)
    QML_NAMED_ELEMENT(CppRecipe)

public:
    struct Ingredient {
        QString name;
        QString quantity;
    };

    enum Roles {
        NameRole = Qt::UserRole,
        QuantityRole
    };

    explicit Recipe(QObject *parent = nullptr);
    Recipe(int recipeId, const QString &pathImage, const QString &title,
           int preparationTime, int cookingTime, int yield, const QString &instructions,
           const QList<Ingredient*> &ingredientsList, QObject *parent = nullptr);
    ~Recipe();

    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

signals:
    void recipeIdChanged();
    void pathImageChanged();
    void titleChanged();
    void preparationTimeChanged();
    void cookingTimeChanged();
    void yieldChanged();
    void instructionsChanged();

public slots:
    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    int recipeId() const;
   void setRecipeId(int newRecipeId);

   const QString pathImage() const;
   void setPathImage(const QString &newTitle);

   const QString title() const;
   void setTitle(const QString &newTitle);

   int preparationTime() const;
   void setPreparationTime(const int newPreparationTime);

   int cookingTime() const;
   void setCookingTime(const int newCookingTime);

   int yield() const;
   void setYield(const int newYield);

   const QString instructions() const;
   void setInstructions(const QString &newInstructions);

    const QString name(int index) const;
    void setNameAt(int index, const QString &newName);
    const QString quantity(int index) const;
    void setQuantityAt(int index, const QString &newQuantity);
    void setIngredientAt(int index, const QString &newName, const QString &newQuantity);
    void appendIngredient(const QString &newName = "", const QString &newQuantity = "");
    void removeIngredientAt(int index);
    void removeAllIngredients();
    void getIngredients();

    // Add recipe to database
    void addRecipe();
    void updateRecipe();
    bool deleteRecipe();
    Recipe *clone();
    bool isEmpty();

private:
    int mRecipeId = -1;
    QString mPathImage = "";
    QString mTitle = "";
    int mPreparationTime = 0;
    int mCookingTime = 0;
    int mYield = 0;
    QString mInstructions = "";

    QList<Ingredient*> mIngredientsList;
};

Q_DECLARE_METATYPE(Recipe::Ingredient*)
#endif // RECIPE_H
