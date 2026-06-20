#pragma once

#include "ForsettiGovernance/Contracts.hpp"

#include <fstream>
#include <sstream>

namespace ForsettiGovernance {

class WindowsFileSystem final : public IFileSystem {
public:
    bool fileExists(const std::filesystem::path& path) const override {
        return std::filesystem::is_regular_file(path);
    }

    std::string readText(const std::filesystem::path& path) const override {
        std::ifstream input(path, std::ios::binary);
        std::ostringstream buffer;
        buffer << input.rdbuf();
        return buffer.str();
    }

    void writeTextAtomically(const std::filesystem::path& path, const std::string& content) const override {
        const auto temporary = path.string() + ".tmp";
        {
            std::ofstream output(temporary, std::ios::binary | std::ios::trunc);
            output << content;
        }
        std::filesystem::rename(temporary, path);
    }

    std::filesystem::path currentDirectory() const override {
        return std::filesystem::current_path();
    }
};

} // namespace ForsettiGovernance
