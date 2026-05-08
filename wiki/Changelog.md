# Changelog

> **Canonical source**: `changelog/CHANGELOG.md`
> **Last synced**: 2026-05-08, FAE-TASK-2026-05-08-006 local validator CLI

All notable changes to the Forsetti Agentic Edition governance framework are documented in this file.

The changelog is a governance record. Entries must be accurate, specific, and traceable.

## [Unreleased]

### Features

**Title**: Add portable local validator CLI
**Change Class**: feature
**Version Impact**: minor
**Summary**: Added a PowerShell-native local validator under `core/validator/`, a machine-readable validator result schema, and root validation wrappers that delegate to the core validator. This establishes a repository-local validation entry point for later contract, policy path, adapter, and final acceptance phases.
**Affected Area**: core, validator, schemas, scripts, documentation, changelog, contracts
**PR Reference**: pending pull request for `fix/v3-local-validator-cli`
**Task Reference**: FAE-TASK-2026-05-08-006
**Approval Class**: governance-class

### Breaking Changes

**Title**: Breaking: Establish canonical compliance rule registry
**Change Class**: breaking-change
**Version Impact**: major
**Summary**: Established `core/policies/compliance-rules.json` as the canonical registry for `FAE-C001` through `FAE-C012`, mirrored the compatibility registry at `policies/compliance-rules.json`, aligned repository boundary manifests, and updated policy and wiki references so Markdown and JSON use the same compliance rule meanings.
**Affected Area**: compliance, policies, core, documentation, changelog, contracts
**PR Reference**: pending pull request for `fix/v3-canonical-policy-registry`
**Task Reference**: FAE-GOV-2026-05-08-005
**Approval Class**: governance-class
**breaking_change**: true
**migration_note**: Consumers that referenced old Markdown rule meanings must update to the canonical registry: `FAE-C003` is Role Separation Enforcement, `FAE-C004` is Protected Asset Governance Gate, `FAE-C005` is Changelog Entry Required for Substantive Changes, `FAE-C006` is Breaking Change Disclosure Mandate, `FAE-C007` is Completion Summary Truthfulness, `FAE-C008` is Documentation Sync Compliance, `FAE-C009` is Version Classification Accuracy, `FAE-C010` is Governance Change Isolation, `FAE-C011` is Evidence and Validation Integrity, and `FAE-C012` is AI Assistance Disclosure and Human Accountability.
**Migration Guidance**: Consumers that referenced old Markdown rule meanings must update to the canonical registry: `FAE-C003` is Role Separation Enforcement, `FAE-C004` is Protected Asset Governance Gate, `FAE-C005` is Changelog Entry Required for Substantive Changes, `FAE-C006` is Breaking Change Disclosure Mandate, `FAE-C007` is Completion Summary Truthfulness, `FAE-C008` is Documentation Sync Compliance, `FAE-C009` is Version Classification Accuracy, `FAE-C010` is Governance Change Isolation, `FAE-C011` is Evidence and Validation Integrity, and `FAE-C012` is AI Assistance Disclosure and Human Accountability.
**Affected Consumers**: Validators, policy readers, documentation sync checks, workflow adapters, contract authors, and release reviewers that consume compliance rule identifiers or policy manifests.

### Governance

**Title**: Repair docs sync policy manifest paths
**Change Class**: governance
**Version Impact**: governance-only
**Summary**: Corrected `policies/docs-sync-rules.json` so documentation sync pairs reference current repository canonical sources and wiki-derived pages required by `DOCUMENTATION_POLICY.md`, including the missing documentation page, instead of stale `docs/*`, `CONSTITUTION.md`, and root `CHANGELOG.md` paths.
**Affected Area**: policies, wiki, changelog, contracts
**PR Reference**: pending pull request for `fix/v3-docs-sync-rules-drift`
**Task Reference**: FAE-GOV-2026-05-08-004
**Approval Class**: governance-class

### Features

**Title**: Add portable core, adapter, and overlay scaffold
**Change Class**: feature
**Version Impact**: minor
**Summary**: Added the Phase 01 portable scaffold for `core/`, `adapters/`, and `overlays/` so host-neutral governance doctrine is separated from optional host integrations and platform-specific execution guidance.
**Affected Area**: core, adapters, overlays, README, wiki, changelog, contracts
**PR Reference**: pending pull request for `fix/v3-portable-core-scaffold`
**Task Reference**: FAE-TASK-2026-05-08-002
**Approval Class**: sensitive

### Bugfixes

**Title**: Fix Windows validator repository-root resolution
**Change Class**: bugfix
**Version Impact**: patch
**Summary**: Corrected `scripts/validate-repo.ps1` so it resolves the Forsetti repository root as the parent of the `scripts/` directory instead of the parent workspace. This prevents false missing-file errors and unrelated JSON parsing failures when validating from the Windows project folder.
**Affected Area**: scripts, changelog, contracts
**PR Reference**: pending pull request for `fix/v3-portable-core-scaffold`
**Task Reference**: FAE-BUG-2026-05-08-001
**Approval Class**: standard

## [1.0.0] - 2026-03-16

### Initial Release

**Title**: Forsetti Agentic Edition v1.0.0 - Foundation Release
**Change Class**: feature
**Version Impact**: major
**Summary**: Initial release of the Forsetti Agentic Edition governance framework, establishing the complete governance layer for AI-led software delivery. Includes constitutional governance, 5 governed roles, contract-driven workflow, compliance model, release policy, documentation policy, machine-readable policy manifests, JSON validation schemas, GitHub workflow enforcement, and wiki seed layer.
**Affected Area**: All - complete framework establishment

**Included Components**:
- FORSETTI_CONSTITUTION.md - foundational governance principles and authority hierarchy
- COMPLIANCE_POLICY.md - evidence-based compliance model with 10 blocking violations
- CHANGE_CONTROL_POLICY.md - 8 change classes, 5 approval classes, scope control
- RELEASE_POLICY.md - versioning model, release readiness, batch release handling
- DOCUMENTATION_POLICY.md - canonical source rule, wiki synchronization, drift detection
- VISION.md - mission, problem statement, strategic goals
- AGENTS.md - primary agent instructions, role model, global rules
- README.md - repository identity, structure, quick start
- CONTRIBUTING.md - contributor guide with governance requirements
- CODE_OF_DELIVERY.md - delivery doctrine and anti-patterns
- 5 agent role definitions (agents/)
- 4 contract templates (contracts/)
- 7 machine-readable policy manifests (policies/)
- 3 JSON validation schemas (schemas/)
- 5 operational standards (standards/)
- 6 GitHub workflows (.github/workflows/)
- 4 issue templates (.github/ISSUE_TEMPLATE/)
- PR template, CODEOWNERS, labels
- 7 wiki seed pages (wiki/)
- 2 guardrail validation scripts (scripts/)

## Navigation

[Home](Home) | [Overview](Overview) | [Constitution](Constitution) | [Agent Roles](Agent-Roles) | [Workflow](Workflow) | [Compliance](Compliance) | [Releases](Releases) | [Changelog](Changelog) | [Glossary](Glossary)
