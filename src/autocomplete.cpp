#include "autocomplete.h"
#include "db_manager.h"

#include <QSqlQuery>


Autocomplete::Autocomplete(const QString &connectionName, QObject *parent) :
    mConnectionName(connectionName)
{
}

QHash<int, QByteArray> Autocomplete::roleNames() const
{
    static QHash<int, QByteArray> names {
        {Title, "title"},
        {Ingredient, "ingredient"}
    };
    return names;
}

int Autocomplete::rowCount(const QModelIndex &parent) const
{
    return mSuggestions.count();
}

void Autocomplete::setConnectionName(const QString &newConnectionName)
{
    if (mConnectionName == newConnectionName)
        return;

    mConnectionName = newConnectionName;
}

const QList<QString> Autocomplete::suggestions() const
{
    return mSuggestions;
}

const QString Autocomplete::suggestionAt(int index) const
{
    if (index >= 0 && index < mSuggestions.size())
        return mSuggestions.at(index);

    return "";
}

QVariant Autocomplete::suggestions(int role, const QString &input)
{
    switch (role) {
    case Title:
        return titleSuggestions(input);;

    case Ingredient:
        return ingredientSuggestions(input);

    default:
        return QVariant();
    }
}

QVariant Autocomplete::titleSuggestions(const QString &input)
{
    QSqlDatabase db = QSqlDatabase::database(mConnectionName);
    QSqlQuery query(db);
    QString strQuery;

    strQuery.append("SELECT DISTINCT title"
                    " FROM recipes"
                    " WHERE ifnull(title, '') <> '' AND title LIKE ?"
                    " ORDER BY title");
    query.prepare(strQuery);
    query.addBindValue("%" + input.simplified() + "%");

    if(!query.exec())
        qWarning() << DbManager::errorMessage(query);

    beginResetModel();
    mSuggestions.clear();
    endResetModel();

    while (query.next()) {
        beginInsertRows(QModelIndex(), mSuggestions.count(), mSuggestions.count());
        mSuggestions.append(query.value("title").toString());
        endInsertRows();
    }

    return mSuggestions;
}

QVariant Autocomplete::ingredientSuggestions(const QString &input)
{
    QSqlDatabase db = QSqlDatabase::database(mConnectionName);
    QSqlQuery query(db);
    QString strQuery;

    strQuery.append("SELECT DISTINCT ingredientName"
                    " FROM ingredients"
                    " WHERE ifnull(ingredientName, '') <> '' AND ingredientName LIKE ?"
                    " ORDER BY ingredientName");
    query.prepare(strQuery);
    query.addBindValue("%" + input.simplified() + "%");

    if(!query.exec())
        qWarning() << DbManager::errorMessage(query);

    beginResetModel();
    mSuggestions.clear();
    endResetModel();

    while (query.next()) {
        beginInsertRows(QModelIndex(), mSuggestions.count(), mSuggestions.count());
        mSuggestions.append(query.value("ingredientName").toString());
        endInsertRows();
    }

    return mSuggestions;
}
