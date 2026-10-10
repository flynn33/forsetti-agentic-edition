# Build the external governance SDK toolkit

Task ID: FAE-TASK-2026-10-10-017
Date: 2026-10-10
Branch: sdk-release
Change class: feature
Approval class: sensitive
Release impact: minor
Contract authoring role: architect
Acting role: builder
Reviewer role: validator (separate review after implementation)
Documentation review role: documentation_manager
Release review role: release_manager
Initiating request: Jim Daley requested implementation of Forsetti-Agentic-SDK-Codex-Instructions.md, pushing and publishing as him without automation attribution; admin bypass is authorized when needed.

## Context and objective

Repository mode: governance_repo for Agentic governance tools. Product release 1.2.0; product bundle schema 2.0; profile/manifest versions remain Apple 0.1.5 / explicit 0.1.3 and Windows 0.2.0 / selected manifest 1.1. External developer toolkit; macOS host and portable PowerShell consumers; no app module or runtime dependency. No application capabilities requested; no application runtime implementation or private framework use.

Build an explicitly allowlisted, repeatable SDK archive with complete doctrine/policy, approved templates, corrected instruction block, bounded safe setup/validation tools, trusted bundle and actual verified native executable where available. Never package the development tree, fixtures, historical evidence, or runtime frameworks. Installation writes only reviewed .forsetti metadata and a managed AGENTS section to temporary fixtures. Preserve unrelated text/files and changed context/locks, reject unsafe paths and malformed managed blocks, make dry runs/idempotence/conflicts explicit, and document partial-write recovery. Verify extracted artifacts outside the development tree.

## In scope

- sdk/** (consumer docs, source map, templates for delivery, PowerShell wrappers)
- scripts/bundle-source-map.json
- scripts/generate-product-manifest.py
- scripts/build-sdk.py
- tests/test_sdk_packaging.py
- tests/test_sdk_installation.py
- products/apple/Sources/** (bounded bootstrap/integrity fixes and version consistency only)
- products/apple/Tests/** (focused native regression cases)
- products/windows/src/Core/BundleVerifier.cpp, products/windows/src/CLI/main.cpp (integrity/version consistency only)
- products/windows/tests/result_tests.cpp
- README.md, wiki/**, changelog/CHANGELOG.md (SDK documentation and distinct feature entry)
- contracts/FAE-TASK-2026-10-10-017-sdk-toolkit.md

## Out of scope

Canonical governance changes covered by FAE-GOV-2026-10-10-016; root maintainer AGENTS/constitution/policy changes; app runtime repositories and real applications; new native task engine; new hosted workflows/settings; GitHub template filename remediation; wholesale native-library embedding distribution.

## Acceptance and evidence

Run existing repository/conformance/native tests and focused positive/negative SDK checks. Exact payload allowlist and source map; canonical mirror and policy byte equality; bundle verifier; archive checksums; no missing/extra/tampered/traversal/symlink inputs; repeated assembly equality. Execute advertised host commands on their actual platforms; omit native variants without native evidence. Test clean and noncompliant profile fixtures, changed-file evidence, installations/upgrades/conflicts/dry run, SDK paths with spaces, and unchanged app/build files. Builder tests are execution evidence; a separate validator must review before release readiness is claimed.

Documentation: README, wiki summaries, consumer guides, command matrix, compatibility, source references and distinct feature changelog entry. Backward compatible, additive CLI-first packaging; existing native library products retained. No framework profile alignment claim beyond pinned sources. Risks: unavailable Windows host/toolchains; clean recorded revision and signing must be verified before publication. Escalate through contract amendment before scope expansion.
