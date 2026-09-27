#pragma once

#include <QString>
#include <optional>
#include <cstdint>
#include <vector>

struct GpuProcessInfo
{
    uint32_t pid = 0;
    QString name;
    uint64_t memoryUsed = 0;
    QString type;
};

struct GpuInfo
{
    int index = -1;

    QString vendor;
    QString name;
    QString uuid;

    // Memory
    std::optional<uint64_t> memoryTotal;
    std::optional<uint64_t> memoryUsed;
    std::optional<uint64_t> memoryFree;

    // Utilization
    std::optional<double> gpuUtilization;
    std::optional<double> memoryUtilization;

    // Thermal / power
    std::optional<double> temperature;
    std::optional<double> powerUsage;
    std::optional<double> powerLimit;

    // Clocks
    std::optional<uint32_t> graphicsClock;
    std::optional<uint32_t> memoryClock;

    // NVIDIA information
    std::optional<uint32_t> fanSpeed;
    std::optional<int> performanceState;

    std::optional<uint32_t> pcieGeneration;
    std::optional<uint32_t> pcieLinkWidth;

    QString driverVersion;
    QString cudaVersion;

    // Running GPU processes
    std::vector<GpuProcessInfo> processes;
};
