#include "NvidiaProvider.h"

#include <QString>

#include <algorithm>
#include <cstring>

NvidiaProvider::NvidiaProvider()
{
    nvmlReturn_t result = nvmlInit();

    if (result == NVML_SUCCESS)
        m_initialized = true;
}

NvidiaProvider::~NvidiaProvider()
{
    if (m_initialized)
        nvmlShutdown();
}

QString NvidiaProvider::vendor() const
{
    return QStringLiteral("NVIDIA");
}

bool NvidiaProvider::isAvailable() const
{
    return m_initialized;
}

std::vector<GpuInfo> NvidiaProvider::enumerateGpus()
{
    std::vector<GpuInfo> gpus;

    if (!m_initialized)
        return gpus;

    unsigned int count = 0;

    if (nvmlDeviceGetCount_v2(&count) != NVML_SUCCESS)
        return gpus;

    for (unsigned int i = 0; i < count; ++i)
    {
        nvmlDevice_t device;

        if (nvmlDeviceGetHandleByIndex_v2(
                i,
                &device) != NVML_SUCCESS)
        {
            continue;
        }

        GpuInfo info;

        info.index = static_cast<int>(i);
        info.vendor = vendor();

        char name[NVML_DEVICE_NAME_V2_BUFFER_SIZE] = {};

        if (nvmlDeviceGetName(
                device,
                name,
                sizeof(name)) == NVML_SUCCESS)
        {
            info.name = QString::fromUtf8(name);
        }

        char uuid[NVML_DEVICE_UUID_BUFFER_SIZE] = {};

        if (nvmlDeviceGetUUID(
                device,
                uuid,
                sizeof(uuid)) == NVML_SUCCESS)
        {
            info.uuid = QString::fromUtf8(uuid);
        }

        gpus.push_back(info);
    }

    return gpus;
}

GpuInfo NvidiaProvider::readGpu(int index)
{
    GpuInfo info;

    info.index = index;
    info.vendor = vendor();

    if (!m_initialized || index < 0)
        return info;

    nvmlDevice_t device;

    if (nvmlDeviceGetHandleByIndex_v2(
            static_cast<unsigned int>(index),
            &device) != NVML_SUCCESS)
    {
        return info;
    }

    // ============================================================
    // BASIC INFORMATION
    // ============================================================

    char name[NVML_DEVICE_NAME_V2_BUFFER_SIZE] = {};

    if (nvmlDeviceGetName(
            device,
            name,
            sizeof(name)) == NVML_SUCCESS)
    {
        info.name = QString::fromUtf8(name);
    }

    char uuid[NVML_DEVICE_UUID_BUFFER_SIZE] = {};

    if (nvmlDeviceGetUUID(
            device,
            uuid,
            sizeof(uuid)) == NVML_SUCCESS)
    {
        info.uuid = QString::fromUtf8(uuid);
    }

    // ============================================================
    // MEMORY
    // ============================================================

    nvmlMemory_t memory{};

    if (nvmlDeviceGetMemoryInfo(
            device,
            &memory) == NVML_SUCCESS)
    {
        info.memoryTotal = memory.total;
        info.memoryUsed = memory.used;
        info.memoryFree = memory.free;
    }

    // ============================================================
    // UTILIZATION
    // ============================================================

    nvmlUtilization_t utilization{};

    if (nvmlDeviceGetUtilizationRates(
            device,
            &utilization) == NVML_SUCCESS)
    {
        info.gpuUtilization =
            utilization.gpu;

        info.memoryUtilization =
            utilization.memory;
    }

    // ============================================================
    // TEMPERATURE
    // ============================================================

    unsigned int temperature = 0;

    if (nvmlDeviceGetTemperature(
            device,
            NVML_TEMPERATURE_GPU,
            &temperature) == NVML_SUCCESS)
    {
        info.temperature =
            static_cast<double>(temperature);
    }

    // ============================================================
    // GRAPHICS CLOCK
    // ============================================================

    unsigned int graphicsClock = 0;

    if (nvmlDeviceGetClockInfo(
            device,
            NVML_CLOCK_GRAPHICS,
            &graphicsClock) == NVML_SUCCESS)
    {
        info.graphicsClock = graphicsClock;
    }

    // ============================================================
    // MEMORY CLOCK
    // ============================================================

    unsigned int memoryClock = 0;

    if (nvmlDeviceGetClockInfo(
            device,
            NVML_CLOCK_MEM,
            &memoryClock) == NVML_SUCCESS)
    {
        info.memoryClock = memoryClock;
    }

    // ============================================================
    // POWER
    // ============================================================

    unsigned int powerUsage = 0;

    if (nvmlDeviceGetPowerUsage(
            device,
            &powerUsage) == NVML_SUCCESS)
    {
        info.powerUsage =
            powerUsage / 1000.0;
    }

    unsigned int powerLimit = 0;

    if (nvmlDeviceGetPowerManagementLimit(
            device,
            &powerLimit) == NVML_SUCCESS)
    {
        info.powerLimit =
            powerLimit / 1000.0;
    }

    // ============================================================
    // FAN
    // ============================================================

    unsigned int fanSpeed = 0;

    if (nvmlDeviceGetFanSpeed(
            device,
            &fanSpeed) == NVML_SUCCESS)
    {
        info.fanSpeed = fanSpeed;
    }

    // ============================================================
    // PERFORMANCE STATE
    // ============================================================

    nvmlPstates_t performanceState;

    if (nvmlDeviceGetPerformanceState(
            device,
            &performanceState) == NVML_SUCCESS)
    {
        info.performanceState =
            static_cast<int>(performanceState);
    }

    // ============================================================
    // PCIe
    // ============================================================

    unsigned int pcieGeneration = 0;

    if (nvmlDeviceGetCurrPcieLinkGeneration(
            device,
            &pcieGeneration) == NVML_SUCCESS)
    {
        info.pcieGeneration =
            pcieGeneration;
    }

    unsigned int pcieLinkWidth = 0;

    if (nvmlDeviceGetCurrPcieLinkWidth(
            device,
            &pcieLinkWidth) == NVML_SUCCESS)
    {
        info.pcieLinkWidth =
            pcieLinkWidth;
    }

    // ============================================================
    // DRIVER
    // ============================================================

    char driverVersion[
        NVML_SYSTEM_DRIVER_VERSION_BUFFER_SIZE
    ] = {};

    if (nvmlSystemGetDriverVersion(
            driverVersion,
            sizeof(driverVersion)) == NVML_SUCCESS)
    {
        info.driverVersion =
            QString::fromUtf8(driverVersion);
    }

    // ============================================================
    // CUDA
    // ============================================================

    int cudaDriverVersion = 0;

    if (nvmlSystemGetCudaDriverVersion(
            &cudaDriverVersion) == NVML_SUCCESS)
    {
        const int major =
            cudaDriverVersion / 1000;

        const int minor =
            (cudaDriverVersion % 1000) / 10;

        info.cudaVersion =
            QString("%1.%2")
                .arg(major)
                .arg(minor);
    }

    // ============================================================
    // RUNNING PROCESSES
    // ============================================================

    auto readProcessList =
        [&](nvmlProcessInfo_t *processes,
            unsigned int count,
            const QString &type)
    {
        for (unsigned int i = 0; i < count; ++i)
        {
            GpuProcessInfo process;

            process.pid =
                processes[i].pid;

            process.memoryUsed =
                processes[i].usedGpuMemory;

            process.type = type;

            char processPath[1024] = {};

            unsigned int pathLength =
                sizeof(processPath);

            if (nvmlSystemGetProcessName(
                    process.pid,
                    processPath,
                    pathLength) == NVML_SUCCESS)
            {
                process.name =
                    QString::fromUtf8(processPath);
            }

            if (process.name.isEmpty())
            {
                process.name =
                    QStringLiteral("PID %1")
                        .arg(process.pid);
            }

            info.processes.push_back(
                std::move(process)
            );
        }
    };

    // ------------------------------------------------------------
    // GRAPHICS PROCESSES
    // ------------------------------------------------------------

    unsigned int graphicsCount = 0;

    nvmlReturn_t result =
        nvmlDeviceGetGraphicsRunningProcesses_v3(
            device,
            &graphicsCount,
            nullptr
        );

    if (result == NVML_ERROR_INSUFFICIENT_SIZE &&
        graphicsCount > 0)
    {
        std::vector<nvmlProcessInfo_t> processes(
            graphicsCount
        );

        if (nvmlDeviceGetGraphicsRunningProcesses_v3(
                device,
                &graphicsCount,
                processes.data()) == NVML_SUCCESS)
        {
            readProcessList(
                processes.data(),
                graphicsCount,
                QStringLiteral("Graphics")
            );
        }
    }

    // ------------------------------------------------------------
    // COMPUTE PROCESSES
    // ------------------------------------------------------------

    unsigned int computeCount = 0;

    result =
        nvmlDeviceGetComputeRunningProcesses_v3(
            device,
            &computeCount,
            nullptr
        );

    if (result == NVML_ERROR_INSUFFICIENT_SIZE &&
        computeCount > 0)
    {
        std::vector<nvmlProcessInfo_t> processes(
            computeCount
        );

        if (nvmlDeviceGetComputeRunningProcesses_v3(
                device,
                &computeCount,
                processes.data()) == NVML_SUCCESS)
        {
            readProcessList(
                processes.data(),
                computeCount,
                QStringLiteral("Compute")
            );
        }
    }

    // ============================================================
    // SORT BY VRAM USAGE
    // ============================================================

    std::sort(
        info.processes.begin(),
        info.processes.end(),
        [](const GpuProcessInfo &a,
           const GpuProcessInfo &b)
        {
            return a.memoryUsed >
                   b.memoryUsed;
        }
    );

    return info;
}
