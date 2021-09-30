#include "db_manager.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[])
{
    const QString path = "cookbook.db";

    DbManager db(path);
    if (db.isOpen()) {
        if (db.createTables()) {
            qDebug() << "Tables created";
        } else {
            exit(-1);
        }
    } else {
        qDebug() << "Connection with database fail" << Qt::endl;
        exit(-1);
    }

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    engine.addImportPath(":/imports");
    engine.load(QUrl(QLatin1String("qrc:/main.qml")));

    return app.exec();
}
