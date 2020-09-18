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

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
