#pragma once

#include "IGpuProvider.h"

#include <nvml.h>

class NvidiaProvider final : public IGpuProvider
{
public:
    NvidiaProvider();
    ~NvidiaProvider() override;

    QString vendor() const override;
    bool isAvailable() const override;

    std::vector<GpuInfo> enumerateGpus() override;
    GpuInfo readGpu(int index) override;

private:
    bool m_initialized = false;
};
