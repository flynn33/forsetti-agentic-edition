# Phase 02 Native Product Scaffold

## Status

Completed.

## Scope

- Added the Apple native Swift package under `products/apple`.
- Added the Windows native C++20 product scaffold under `products/windows`.
- Added shared conformance fixture root under `tests/conformance`.
- Established shared result contracts, exit-code mapping, bundle verification, version reporting, and command routing.

## Architecture

The native products are split into strict platform layers:

- `GovernanceContracts` and `include/ForsettiGovernance/Contracts.hpp` define dependency contracts.
- `GovernanceCore` and `src/Core` define result models, version output, and deterministic serialization.
- `GovernanceApple` and `src/Windows` isolate host filesystem and platform behavior.
- `ForsettiGovernanceCLI` and `src/CLI` compose the executable entry points.

## Verification

| Command | Result |
| --- | --- |
| `swift test --package-path products/apple` | Passed; 2 tests executed. |
| `swift build --package-path products/apple -c release` | Passed; release executable built. |
| `products/apple/.build/release/forsetti-governance version --format json` | Passed; returned structured version result. |
| `products/apple/.build/release/forsetti-governance bundle verify --bundle-root /tmp/ffae-missing-bundle --format json` | Passed expected fail-closed behavior; exited 4 with `bundle.manifest.missing`. |
| `clang++ -std=c++20 -Iproducts/windows/include products/windows/src/Core/Result.cpp products/windows/src/Core/BundleVerifier.cpp products/windows/src/CLI/main.cpp -o /tmp/forsetti-governance-cpp-check` | Passed; Windows product sources compiled with local C++20 compiler. |
| `/tmp/forsetti-governance-cpp-check version --format json` | Passed; returned structured version result. |
| `/tmp/forsetti-governance-cpp-check bundle verify --bundle-root /tmp/ffae-missing-bundle --format json` | Passed expected fail-closed behavior; exited 4 with `bundle.manifest.missing`. |
| `clang++ -std=c++20 -Iproducts/windows/include products/windows/src/Core/Result.cpp products/windows/tests/result_tests.cpp -o /tmp/forsetti-governance-result-tests` | Passed; C++ result test compiled. |
| `/tmp/forsetti-governance-result-tests` | Passed. |

## Local Limits

- `cmake` is not installed in this environment, so the Windows `CMakeLists.txt` path was validated by direct C++20 compilation instead of a CMake configure/build.
- The native products intentionally remain at repository version `1.0.0` until the release-version phase is reached.
