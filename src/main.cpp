#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "core/GpuController.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    GpuController gpuController;

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty(
        "gpuController",
        &gpuController
    );

    engine.loadFromModule("GPUConsole", "Main");

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
