#ifndef AUTOCOMPLETE_H
#define AUTOCOMPLETE_H

#include <QStringListModel>
#include <QtQml/qqml.h>

class Autocomplete : public QStringListModel {
    Q_OBJECT
    QML_NAMED_ELEMENT(CppAutocomplete)

public:
    enum AutocompleteEnum {
        Title,
        Ingredient
    };
    Q_ENUM(AutocompleteEnum)

    explicit Autocomplete(const QString &connectionName, QObject *parent = nullptr);

    QHash<int, QByteArray> roleNames() const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

public slots:
    void setConnectionName(const QString &newConnectionName = "");
    const QList<QString> suggestions() const;
    const QString suggestionAt(int index) const;
    QVariant suggestions(int role, const QString &input);

private:
    QVariant titleSuggestions(const QString &input);
    QVariant ingredientSuggestions(const QString &input);

public:
    QString mConnectionName;
    QList<QString> mSuggestions;
};

#endif // AUTOCOMPLETE_H
