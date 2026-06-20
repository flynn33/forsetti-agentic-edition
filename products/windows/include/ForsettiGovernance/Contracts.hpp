#pragma once

#include <filesystem>
#include <string>
#include <vector>

namespace ForsettiGovernance {

struct ValidationResult;

struct ProcessResult final {
    std::string executable;
    std::vector<std::string> arguments;
    std::filesystem::path workingDirectory;
    int exitCode = 0;
    std::string standardOutput;
    std::string standardError;
};

class IFileSystem {
public:
    virtual ~IFileSystem() = default;
    virtual bool fileExists(const std::filesystem::path& path) const = 0;
    virtual std::string readText(const std::filesystem::path& path) const = 0;
    virtual void writeTextAtomically(const std::filesystem::path& path, const std::string& content) const = 0;
    virtual std::filesystem::path currentDirectory() const = 0;
};

class IProcessRunner {
public:
    virtual ~IProcessRunner() = default;
    virtual ProcessResult run(
        const std::string& executable,
        const std::vector<std::string>& arguments,
        const std::filesystem::path& workingDirectory) const = 0;
};

class IGitRepository {
public:
    virtual ~IGitRepository() = default;
    virtual std::string headCommit(const std::filesystem::path& repositoryRoot) const = 0;
    virtual std::vector<std::string> changedFiles(
        const std::filesystem::path& repositoryRoot,
        const std::string& baselineCommit) const = 0;
};

class IBundleVerifier {
public:
    virtual ~IBundleVerifier() = default;
    virtual ValidationResult verify(const std::filesystem::path& bundleRoot) const = 0;
};

class IClock {
public:
    virtual ~IClock() = default;
    virtual std::string nowUTC() const = 0;
};

class IIdentifierGenerator {
public:
    virtual ~IIdentifierGenerator() = default;
    virtual std::string newIdentifier() const = 0;
};

} // namespace ForsettiGovernance
