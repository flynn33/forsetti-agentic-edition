#pragma once

#include "ForsettiGovernance/Contracts.hpp"
#include "ForsettiGovernance/Result.hpp"

namespace ForsettiGovernance {

class SimpleBundleVerifier final : public IBundleVerifier {
public:
    explicit SimpleBundleVerifier(const IFileSystem& fileSystem);

    ValidationResult verify(const std::filesystem::path& bundleRoot) const override;

private:
    const IFileSystem& fileSystem_;
};

} // namespace ForsettiGovernance
