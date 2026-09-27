#pragma once

#include "GpuInfo.h"

#include <memory>
#include <vector>

class IGpuProvider;

class GpuManager
{
public:
    GpuManager();
    ~GpuManager();

    std::vector<GpuInfo> enumerateGpus();
    GpuInfo readGpu(int index);

private:
    struct GpuBinding
    {
        IGpuProvider* provider = nullptr;
        int providerIndex = -1;
    };

    std::vector<std::unique_ptr<IGpuProvider>> m_providers;

    std::vector<GpuBinding> m_gpuBindings;

    std::vector<GpuInfo> m_gpus;

    void rebuildGpuList();
};
