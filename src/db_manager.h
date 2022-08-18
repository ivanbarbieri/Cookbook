#ifndef DBMANAGER_H
#define DBMANAGER_H

#include <QSqlQueryModel>

class DbManager : public QSqlQueryModel
{
    Q_OBJECT
public:
    DbManager();
    DbManager(const QString &driver, const QString &connectionName, const QString &path);
    virtual ~DbManager();

    static const QString errorMessage(const QSqlQuery &query);
    bool isOpen() const;
    bool foreignKeys(bool active = true) const;
    bool createTables() const;
    bool createTriggers() const;

private:
    QSqlDatabase db;
};
#endif // DBMANAGER_H
