#pragma once

#include <QObject>
#include <QString>
#include <QStringList>
#include <QTimer>
#include <QVariantList>

#include "GpuInfo.h"

class GpuManager;

class GpuController : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString vendor
               READ vendor
               NOTIFY gpuChanged)

    Q_PROPERTY(QString name
               READ name
               NOTIFY gpuChanged)

    Q_PROPERTY(QString uuid
               READ uuid
               NOTIFY gpuChanged)

    Q_PROPERTY(double memoryTotal
               READ memoryTotal
               NOTIFY metricsChanged)

    Q_PROPERTY(double memoryUsed
               READ memoryUsed
               NOTIFY metricsChanged)

    Q_PROPERTY(double memoryFree
               READ memoryFree
               NOTIFY metricsChanged)

    Q_PROPERTY(double gpuUtilization
               READ gpuUtilization
               NOTIFY metricsChanged)

    Q_PROPERTY(double memoryUtilization
               READ memoryUtilization
               NOTIFY metricsChanged)

    Q_PROPERTY(double temperature
               READ temperature
               NOTIFY metricsChanged)

    Q_PROPERTY(double powerUsage
               READ powerUsage
               NOTIFY metricsChanged)

    Q_PROPERTY(double powerLimit
               READ powerLimit
               NOTIFY metricsChanged)

    Q_PROPERTY(int graphicsClock
               READ graphicsClock
               NOTIFY metricsChanged)

    Q_PROPERTY(int memoryClock
               READ memoryClock
               NOTIFY metricsChanged)

    Q_PROPERTY(QStringList gpuNames
               READ gpuNames
               NOTIFY gpuListChanged)

    Q_PROPERTY(int selectedGpu
               READ selectedGpu
               WRITE setSelectedGpu
               NOTIFY selectedGpuChanged)

    Q_PROPERTY(QVariantList gpuUtilizationHistory
               READ gpuUtilizationHistory
               NOTIFY historyChanged)

    Q_PROPERTY(QVariantList memoryUtilizationHistory
               READ memoryUtilizationHistory
               NOTIFY historyChanged)

    Q_PROPERTY(QVariantList temperatureHistory
               READ temperatureHistory
               NOTIFY historyChanged)

    Q_PROPERTY(QVariantList powerHistory
               READ powerHistory
               NOTIFY historyChanged)

    Q_PROPERTY(int fanSpeed
               READ fanSpeed
               NOTIFY metricsChanged)

    Q_PROPERTY(int performanceState
               READ performanceState
               NOTIFY metricsChanged)

    Q_PROPERTY(int pcieGeneration
               READ pcieGeneration
               NOTIFY metricsChanged)

    Q_PROPERTY(int pcieLinkWidth
               READ pcieLinkWidth
               NOTIFY metricsChanged)

    Q_PROPERTY(QString driverVersion
               READ driverVersion
               NOTIFY gpuChanged)

    Q_PROPERTY(QString cudaVersion
               READ cudaVersion
               NOTIFY gpuChanged)

    Q_PROPERTY(QVariantList processes
               READ processes
               NOTIFY processesChanged)

public:
    explicit GpuController(QObject *parent = nullptr);

    QString vendor() const;
    QString name() const;
    QString uuid() const;

    double memoryTotal() const;
    double memoryUsed() const;
    double memoryFree() const;

    double gpuUtilization() const;
    double memoryUtilization() const;

    double temperature() const;
    double powerUsage() const;
    double powerLimit() const;

    int graphicsClock() const;
    int memoryClock() const;

    int fanSpeed() const;
    int performanceState() const;
    int pcieGeneration() const;
    int pcieLinkWidth() const;

    QString driverVersion() const;
    QString cudaVersion() const;

    QStringList gpuNames() const;

    int selectedGpu() const;
    void setSelectedGpu(int index);

    QVariantList processes() const;

    QVariantList gpuUtilizationHistory() const;
    QVariantList memoryUtilizationHistory() const;
    QVariantList temperatureHistory() const;
    QVariantList powerHistory() const;

signals:
    void gpuChanged();
    void metricsChanged();
    void gpuListChanged();
    void selectedGpuChanged();
    void historyChanged();
    void processesChanged();

private slots:
    void updateMetrics();

private:
    GpuManager *m_manager = nullptr;

    int m_selectedGpu = -1;

    QStringList m_gpuNames;

    GpuInfo m_gpu;

    QTimer m_timer;

    QVariantList m_gpuUtilizationHistory;
    QVariantList m_memoryUtilizationHistory;
    QVariantList m_temperatureHistory;
    QVariantList m_powerHistory;

    static constexpr int MaxHistoryPoints = 60;
};
