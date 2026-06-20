# Phase 03 Trusted Product Bundle

## Status

Completed.

## Files Changed

- `bundle/`
- `scripts/generate-product-manifest.py`
- `products/apple/Sources/GovernanceCore/ProductManifest.swift`
- `products/apple/Sources/GovernanceApple/SHA256BundleVerifier.swift`
- `products/apple/Tests/GovernanceCoreTests/ValidationResultTests.swift`
- `products/windows/include/ForsettiGovernance/SHA256.hpp`
- `products/windows/src/Core/SHA256.cpp`
- `products/windows/src/Core/BundleVerifier.cpp`
- `products/windows/tests/result_tests.cpp`
- `products/windows/CMakeLists.txt`

## Implemented Behavior

- Added a trusted source bundle with schemas, policies, edition profiles, target instructions, and `VERSION`.
- Added deterministic manifest generation through `scripts/generate-product-manifest.py`.
- Generated `bundle/product-manifest.json` with 46 required hashed bundle entries.
- Added SHA-256 verification for Apple and Windows native bundle verification.
- Added fail-closed handling for missing manifest, unsupported manifest version, unsafe path, duplicate path, missing required file, changed hash, and product-lock mismatch.
- Preserved optional missing file behavior as non-blocking.

## Evidence Paths

- `bundle/product-manifest.json`
- `products/apple/Tests/GovernanceCoreTests/ValidationResultTests.swift`
- `products/windows/tests/result_tests.cpp`

## Verification

| Command | Result |
| --- | --- |
| `python3 scripts/generate-product-manifest.py --bundle-root bundle` | Passed; generated deterministic source bundle manifest. |
| `swift test --package-path products/apple` | Passed; 5 tests executed. |
| `swift build --package-path products/apple -c release` | Passed; release executable built. |
| `products/apple/.build/release/forsetti-governance bundle verify --bundle-root bundle --format json` | Passed; source bundle verified. |
| `products/apple/.build/release/forsetti-governance bundle verify --bundle-root /tmp/ffae-missing-bundle --format json` | Passed expected fail-closed behavior; exited 4 with `bundle.manifest.missing`. |
| `clang++ -std=c++20 -Iproducts/windows/include products/windows/src/Core/SHA256.cpp products/windows/src/Core/Result.cpp products/windows/src/Core/BundleVerifier.cpp products/windows/src/CLI/main.cpp -o /tmp/forsetti-governance-cpp-check` | Passed; Windows product sources compiled with local C++20 compiler. |
| `clang++ -std=c++20 -Iproducts/windows/include products/windows/src/Core/SHA256.cpp products/windows/src/Core/Result.cpp products/windows/src/Core/BundleVerifier.cpp products/windows/tests/result_tests.cpp -o /tmp/forsetti-governance-result-tests` | Passed; C++ test executable compiled. |
| `/tmp/forsetti-governance-result-tests` | Passed. |
| `/tmp/forsetti-governance-cpp-check bundle verify --bundle-root bundle --format json` | Passed; source bundle verified. |
| `/tmp/forsetti-governance-cpp-check bundle verify --bundle-root /tmp/ffae-missing-bundle --format json` | Passed expected fail-closed behavior; exited 4 with `bundle.manifest.missing`. |

## Unresolved Findings

- `cmake` is not installed in this environment, so the Windows `CMakeLists.txt` path remains validated by direct C++20 compilation until CMake is available.
- Installed release executable hash verification remains tied to the later release-artifact phase, where platform-specific release bundles are built.

## Exit Decision

Proceed to Phase 04.
