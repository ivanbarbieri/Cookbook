#ifndef DBMANAGER_H
#define DBMANAGER_H

#include <QSqlDatabase>
#include <QSqlQueryModel>

class DbManager : public QSqlQueryModel
{
    Q_OBJECT
public:
    DbManager(const QString &path);
    ~DbManager();

    bool isOpen() const;
    bool createTables();

private:
    QSqlDatabase db;
};
#endif // DBMANAGER_H
