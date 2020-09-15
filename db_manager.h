#ifndef DBMANAGER_H
#define DBMANAGER_H

#include <QSqlDatabase>

class DbManager
{
public:
    DbManager(const QString &path);
    ~DbManager();

    bool isOpen() const;
    bool createTables();

private:
    QSqlDatabase db;
};

#endif // DBMANAGER_H
