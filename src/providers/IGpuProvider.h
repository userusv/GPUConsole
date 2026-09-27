#pragma once

#include "../core/GpuInfo.h"

#include <vector>

class IGpuProvider
{
public:
    virtual ~IGpuProvider() = default;

    virtual QString vendor() const = 0;

    virtual bool isAvailable() const = 0;

    virtual std::vector<GpuInfo> enumerateGpus() = 0;

    virtual GpuInfo readGpu(int index) = 0;
};
