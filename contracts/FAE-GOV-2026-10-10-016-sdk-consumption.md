# Agentic SDK consumption and external validation

Task ID: FAE-GOV-2026-10-10-016
Date: 2026-10-10
Branch: sdk-release
Change class: governance
Approval class: governance-class
Release impact: governance-only
Contract authoring role: architect
Acting role: builder
Reviewer role: validator
Authority: human repository owner Jim Daley, through the instruction to implement the attached Forsetti-Agentic-SDK-Codex-Instructions.md and publish the SDK. This authority covers the explicitly requested consumption policy, accurate downstream instructions, and external validator resource resolution. It does not authorize changing constitutional doctrine or relaxing enforcement.

## Objective and current defect

Establish the Agentic product-data allowlist and make target validation work with immutable toolkit resources outside the consumer repository. The baseline target instruction requires unimplemented native `task` commands and Windows `doctor`. Replace these instructions with actual platform command availability and the existing contract/PowerShell/evidence workflow. Preserve rule identifiers, policy meaning, fail-closed outcomes, independent reviews, and maintainer modes.

## Context

Repository mode: governance_repo (Agentic governance toolkit maintenance).
Product: Forsetti Agentic Edition; baseline 1.1.0.
Target profiles: Apple 0.1.5, explicitly selected Apple 0.1.3, Windows 0.2.0; existing profile paths under editions/. These are separate from the product version.
Target platforms: macOS host; portable PowerShell tooling; Windows native only if built and tested on Windows.
Manifest/template version: existing profile-selected 1.1; existing product bundle schema 2.0.
Deployment: external developer governance toolkit, no application module or runtime dependency.
Capabilities: none requested by this toolkit release. Runtime requirements: not applicable to governance host. Public API only: yes; application framework internals: untouched.

## In scope

- CONSUMPTION_POLICY.md
- core/validator/** (resource root separation, integrity enforcement, and correction of verified core-boundary scanner false positives on its own prohibited-pattern strings and allowed canonical policy data; genuine executable hosted dependencies remain rejected)
- bundle/instructions/target-agents-section.md
- bundle/product-manifest.json (authoritative regeneration after instruction changes)
- bundle/schemas/forsetti-project-context.schema.json, bundle/schemas/module-manifest-1.1.schema.json, bundle/schemas/task-contract.schema.json, bundle/schemas/edition-profile.schema.json (byte-identical canonical core schema mirrors for trusted external validation)
- tests/test_sdk_validator.py
- contracts/FAE-GOV-2026-10-10-016-sdk-consumption.md
- changelog/CHANGELOG.md (individual governance entry)
- README.md, wiki/Overview.md, wiki/Workflow.md, wiki/Documentation.md, wiki/Glossary.md (derived consumption/onboarding documentation)

## Out of scope

Constitution amendments, altered canonical rule registries, application-runtime repositories, real consumer apps, native task orchestration, hosted workflow enabling, repository setting changes, unrelated case-colliding GitHub files.

## Acceptance, impact, and rollback

Complete policy must identify immutable external toolkit assets, allowlisted project-owned metadata, managed locks/instructions, optional adapters, and excluded maintainer source/history. Immutable Apple consumption-policy provenance is a boundary reference, not the Agentic allowlist. Source policy bytes and hash must be preserved in every SDK asset. External target modes must preserve existing enforcement and maintainer commands. Test separated SDK/target paths, altered/missing trusted resources, valid and invalid Apple/Windows fixtures, and real changed-file evidence. Review by a separate validator is required; no independent approval is asserted by the builder.

Backward compatible: existing source-root validation remains supported; no policy meaning or schema changes. Downstream consumers gain an external installation workflow and truthful command instructions. Documentation and a governance changelog entry are required. Rollback: revert this standalone governance change and regenerate the bundle using the authoritative generator; do not modify consumer projects automatically.
