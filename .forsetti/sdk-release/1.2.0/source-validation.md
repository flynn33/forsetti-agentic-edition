# SDK 1.2.0 source validation

Accountable human owner: Jim Daley. Governing contracts: FAE-GOV-2026-10-10-016, FAE-TASK-2026-10-10-017, FAE-REL-2026-10-10-018.

This is source/build evidence. Final recorded-revision archive hashes, extracted command runs, source/network-denial probes, and publication readback are supplied with the release's separate qualification evidence. Builder execution evidence does not establish independent approval or application runtime acceptance.

## Executed checks

- Python repository and SDK tests: 58 passed with no skips, including 16 existing repository tests, 10 packaging tests, 12 installation tests, and 20 target-validator tests. Command: `PWSH=<PowerShell-7.6.6> NATIVE_CLI=<built-native-CLI> PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tests -v`.
- Native macOS tests: 22 passed. Command: `swift test --package-path products/apple --scratch-path <external-build-directory>`.
- Native macOS release build passed with `swift build --package-path products/apple --scratch-path <external-build-directory> -c release --product forsetti-governance`. Actual executable is Mach-O arm64, reports product 1.2.0, and records macOS minimum 13.0.
- Maintainer validator `-Mode all -Strict` passed. Policy registries, profile sources, root/canonical schemas, root AGENTS, and constitution are unchanged. The four new bundle schema mirrors preserve canonical bytes; the existing module-schema alias keeps its explicit schema-ID transformation.
- C++20 core tests compiled and passed on macOS. This is portability evidence, not a Windows build/run.
- The repository's shared conformance directory has no committed fixture cases; SDK consumer and negative fixtures are executed by the new test suites.

Independent review identified and corrected stale canonical bundle acceptance, link-root generation, checksum overwrite, incorrect schema/example paths, literal process/adapter dependency detection, physical toolkit/target overlap, and native SDK-root containment. Policy/documentation and packaging reviews are separate from their builders; separate applicable source review passed after the reproduced regressions were fixed and independently rechecked. Final asset/publication decisions are in release qualification evidence.

## Known limitations

Actual native Windows execution/build/command checks, Windows-host PowerShell execution, Intel macOS native distribution, legacy Windows PowerShell 5.1, and application runtime/native-device acceptance were not verified. Windows native assets are omitted. The published SDK is a prerelease with Windows-host verification explicitly outstanding. Static checks and native bundle verification are not runtime compliance approval. Dynamic executable/dataflow patterns still require independent review.

No constitutional doctrine or policy registry meaning was changed. No hosted workflow was enabled, no repository settings were changed, no real consumer app or runtime repository was modified, and no native task orchestration was implemented. SDK installation writes only approved metadata and a managed instruction section. Required README, wiki summaries, consumer guides, policy, and individual changelog entries are updated. Aggregate release impact is minor; source changes follow the three contracts and separate governance/feature/release changesets.

## Changed files

- `CONSUMPTION_POLICY.md`
- `README.md`
- `VERSION`
- `bundle/VERSION`
- `bundle/instructions/target-agents-section.md`
- `bundle/product-manifest.json`
- `bundle/schemas/edition-profile.schema.json`
- `bundle/schemas/forsetti-project-context.schema.json`
- `bundle/schemas/module-manifest-1.1.schema.json`
- `bundle/schemas/task-contract.schema.json`
- `changelog/CHANGELOG.md`
- `contracts/FAE-GOV-2026-10-10-016-sdk-consumption.md`
- `contracts/FAE-REL-2026-10-10-018-sdk-1.2.0.md`
- `contracts/FAE-TASK-2026-10-10-017-sdk-toolkit.md`
- `core/validator/README.md`
- `core/validator/contract_rules.ps1`
- `core/validator/forsetti_validate.ps1`
- `core/validator/sdk_integrity.ps1`
- `products/apple/Sources/GovernanceApple/LocalFileSystem.swift`
- `products/apple/Sources/GovernanceApple/RepositoryBootstrapService.swift`
- `products/apple/Sources/GovernanceApple/SHA256BundleVerifier.swift`
- `products/apple/Sources/GovernanceCore/CoreTypes.swift`
- `products/apple/Tests/GovernanceCoreTests/ValidationResultTests.swift`
- `products/windows/CMakeLists.txt`
- `products/windows/include/ForsettiGovernance/Result.hpp`
- `products/windows/src/CLI/main.cpp`
- `products/windows/src/Core/BundleVerifier.cpp`
- `products/windows/tests/result_tests.cpp`
- `scripts/build-sdk.py`
- `scripts/bundle-source-map.json`
- `scripts/generate-product-manifest.py`
- `sdk/AGENTS.md`
- `sdk/Documentation/Command-Matrix.md`
- `sdk/Documentation/Compatibility.md`
- `sdk/Documentation/Getting-Started.md`
- `sdk/Documentation/Governance-Workflow.md`
- `sdk/Documentation/Source-References.md`
- `sdk/README.md`
- `sdk/Release-Notes.md`
- `sdk/Tools/Initialize-Consumer.ps1`
- `sdk/Tools/SDK-Integrity.ps1`
- `sdk/Tools/Validate-Consumer.ps1`
- `sdk/payload-map.json`
- `tests/test_sdk_installation.py`
- `tests/test_sdk_packaging.py`
- `tests/test_sdk_validator.py`
- `wiki/Changelog.md`
- `wiki/Documentation.md`
- `wiki/Glossary.md`
- `wiki/Home.md`
- `wiki/Overview.md`
- `wiki/Releases.md`
- `wiki/Workflow.md`
