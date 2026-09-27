#include "GpuManager.h"
#include "../providers/IGpuProvider.h"
#include "../providers/NvidiaProvider.h"

GpuManager::GpuManager()
{
    m_providers.push_back(std::make_unique<NvidiaProvider>());
    rebuildGpuList();
}

GpuManager::~GpuManager() = default;

void GpuManager::rebuildGpuList()
{
    m_gpus.clear();
    m_gpuBindings.clear();

    for (const auto& provider : m_providers)
    {
        if (!provider->isAvailable())
            continue;

        const auto providerGpus = provider->enumerateGpus();

        for (const auto& providerGpu : providerGpus)
        {
            if (providerGpu.index < 0)
                continue;

            GpuInfo gpu = providerGpu;
            const int globalIndex = static_cast<int>(m_gpus.size());
            gpu.index = globalIndex;
            m_gpus.push_back(gpu);

            GpuBinding binding;
            binding.provider = provider.get();
            binding.providerIndex = providerGpu.index;
            m_gpuBindings.push_back(binding);
        }
    }
}

std::vector<GpuInfo> GpuManager::enumerateGpus()
{
    rebuildGpuList();
    return m_gpus;
}

GpuInfo GpuManager::readGpu(int index)
{
    if (index < 0 || static_cast<size_t>(index) >= m_gpuBindings.size())
        return {};

    const GpuBinding& binding = m_gpuBindings[static_cast<size_t>(index)];

    if (!binding.provider || !binding.provider->isAvailable())
        return {};

    GpuInfo gpu = binding.provider->readGpu(binding.providerIndex);

    if (gpu.name.isEmpty())
        return {};

    gpu.index = index;
    return gpu;
}
