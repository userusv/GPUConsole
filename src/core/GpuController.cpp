#include "GpuController.h"

#include "GpuManager.h"

#include <QVariantMap>

GpuController::GpuController(QObject *parent)
    : QObject(parent)
{
    m_manager =
        new GpuManager();

    const auto gpus =
        m_manager->enumerateGpus();

    for (const auto &gpu : gpus)
        m_gpuNames.append(gpu.name);

    if (!gpus.empty())
    {
        m_selectedGpu =
            gpus.front().index;

        m_gpu =
            m_manager->readGpu(
                m_selectedGpu
            );
    }

    emit gpuListChanged();

    connect(
        &m_timer,
        &QTimer::timeout,
        this,
        &GpuController::updateMetrics
    );

    m_timer.start(1000);
}

QStringList GpuController::gpuNames() const
{
    return m_gpuNames;
}

int GpuController::selectedGpu() const
{
    return m_selectedGpu;
}

void GpuController::setSelectedGpu(int index)
{
    if (index == m_selectedGpu)
        return;

    if (index < 0 ||
        index >= m_gpuNames.size())
    {
        return;
    }

    m_selectedGpu = index;

    m_gpu =
        m_manager->readGpu(index);

    m_gpuUtilizationHistory.clear();
    m_memoryUtilizationHistory.clear();
    m_temperatureHistory.clear();
    m_powerHistory.clear();

    emit selectedGpuChanged();
    emit gpuChanged();
    emit metricsChanged();
    emit historyChanged();
    emit processesChanged();
}

void GpuController::updateMetrics()
{
    if (m_selectedGpu < 0)
        return;

    const GpuInfo updated =
        m_manager->readGpu(
            m_selectedGpu
        );

    if (updated.name.isEmpty())
        return;

    m_gpu = updated;

    /*
     * Only add history points for metrics that
     * are actually supported.
     *
     * This prevents Intel unsupported values from
     * becoming fake zero lines in the graphs.
     */

    if (m_gpu.gpuUtilization)
    {
        m_gpuUtilizationHistory.append(
            *m_gpu.gpuUtilization
        );
    }

    if (m_gpu.memoryUtilization)
    {
        m_memoryUtilizationHistory.append(
            *m_gpu.memoryUtilization
        );
    }

    if (m_gpu.temperature)
    {
        m_temperatureHistory.append(
            *m_gpu.temperature
        );
    }

    if (m_gpu.powerUsage)
    {
        m_powerHistory.append(
            *m_gpu.powerUsage
        );
    }

    while (m_gpuUtilizationHistory.size()
           > MaxHistoryPoints)
    {
        m_gpuUtilizationHistory.removeFirst();
    }

    while (m_memoryUtilizationHistory.size()
           > MaxHistoryPoints)
    {
        m_memoryUtilizationHistory.removeFirst();
    }

    while (m_temperatureHistory.size()
           > MaxHistoryPoints)
    {
        m_temperatureHistory.removeFirst();
    }

    while (m_powerHistory.size()
           > MaxHistoryPoints)
    {
        m_powerHistory.removeFirst();
    }

    emit metricsChanged();
    emit historyChanged();
    emit processesChanged();
}

QString GpuController::vendor() const
{
    return m_gpu.vendor;
}

QString GpuController::name() const
{
    return m_gpu.name;
}

QString GpuController::uuid() const
{
    return m_gpu.uuid;
}

double GpuController::memoryTotal() const
{
    return m_gpu.memoryTotal
        ? *m_gpu.memoryTotal /
              (1024.0 * 1024.0)
        : -1.0;
}

double GpuController::memoryUsed() const
{
    return m_gpu.memoryUsed
        ? *m_gpu.memoryUsed /
              (1024.0 * 1024.0)
        : -1.0;
}

double GpuController::memoryFree() const
{
    return m_gpu.memoryFree
        ? *m_gpu.memoryFree /
              (1024.0 * 1024.0)
        : -1.0;
}

double GpuController::gpuUtilization() const
{
    return m_gpu.gpuUtilization
        ? *m_gpu.gpuUtilization
        : -1.0;
}

double GpuController::memoryUtilization() const
{
    return m_gpu.memoryUtilization
        ? *m_gpu.memoryUtilization
        : -1.0;
}

double GpuController::temperature() const
{
    return m_gpu.temperature
        ? *m_gpu.temperature
        : -1.0;
}

double GpuController::powerUsage() const
{
    return m_gpu.powerUsage
        ? *m_gpu.powerUsage
        : -1.0;
}

double GpuController::powerLimit() const
{
    return m_gpu.powerLimit
        ? *m_gpu.powerLimit
        : -1.0;
}

int GpuController::graphicsClock() const
{
    return m_gpu.graphicsClock
        ? static_cast<int>(
              *m_gpu.graphicsClock
          )
        : -1;
}

int GpuController::memoryClock() const
{
    return m_gpu.memoryClock
        ? static_cast<int>(
              *m_gpu.memoryClock
          )
        : -1;
}

int GpuController::fanSpeed() const
{
    return m_gpu.fanSpeed
        ? static_cast<int>(
              *m_gpu.fanSpeed
          )
        : -1;
}

int GpuController::performanceState() const
{
    return m_gpu.performanceState
        ? *m_gpu.performanceState
        : -1;
}

int GpuController::pcieGeneration() const
{
    return m_gpu.pcieGeneration
        ? static_cast<int>(
              *m_gpu.pcieGeneration
          )
        : -1;
}

int GpuController::pcieLinkWidth() const
{
    return m_gpu.pcieLinkWidth
        ? static_cast<int>(
              *m_gpu.pcieLinkWidth
          )
        : -1;
}

QString GpuController::driverVersion() const
{
    return m_gpu.driverVersion;
}

QString GpuController::cudaVersion() const
{
    return m_gpu.cudaVersion;
}

QVariantList GpuController::gpuUtilizationHistory() const
{
    return m_gpuUtilizationHistory;
}

QVariantList GpuController::memoryUtilizationHistory() const
{
    return m_memoryUtilizationHistory;
}

QVariantList GpuController::temperatureHistory() const
{
    return m_temperatureHistory;
}

QVariantList GpuController::powerHistory() const
{
    return m_powerHistory;
}

QVariantList GpuController::processes() const
{
    QVariantList result;

    for (const auto &process : m_gpu.processes)
    {
        QVariantMap item;

        item["pid"] =
            static_cast<int>(
                process.pid
            );

        item["name"] =
            process.name;

        item["memoryUsed"] =
            static_cast<qulonglong>(
                process.memoryUsed
            );

        item["memoryMiB"] =
            process.memoryUsed /
            (1024.0 * 1024.0);

        item["type"] =
            process.type;

        result.append(item);
    }

    return result;
}
