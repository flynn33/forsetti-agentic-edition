# Changelog

> **Canonical source**: `changelog/CHANGELOG.md`
> **Last synced**: 2026-05-11, FAE-GOV-2026-05-11-012 AI assistance accountability policy

All notable changes to the Forsetti Agentic Edition governance framework are documented in this file.

The changelog is a governance record. Entries must be accurate, specific, and traceable.

## [Unreleased]

### Documentation

**Title**: Document GitHub Actions adapter conversion
**Change Class**: docs
**Version Impact**: patch
**Summary**: Updated README, adapter guide, wiki, and release traceability documentation to describe the Phase 06A conversion of GitHub Actions workflows into optional adapter-owned scripts while keeping final Phase 06 acceptance dependent on the Phase 06B evidence.
**Affected Area**: README, adapters, wiki, changelog, remediation evidence
**PR Reference**: pending pull request for `fix/v3-github-adapter-docs-06b`
**Task Reference**: FAE-TASK-2026-05-11-011
**Approval Class**: standard
**Phase 06A Reference**: PR #6, merge commit `0c0a2cf6fa4b99de1bd839332991ec26ba6c354e`, evidence under `.forsetti/remediation-v3/phase-06a-*`

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

**Title**: Breaking: Establish AI assistance accountability without attribution
**Change Class**: breaking-change
**Version Impact**: major
**Summary**: Added a compliance support policy and machine-readable manifest requiring a human accountable owner, governed role, contract or phase reference, review evidence, validation evidence, and required approval evidence while prohibiting attribution credit to tools, models, vendors, automation, or agents across governed delivery surfaces. Consumers must now collect and validate the accountability record for AI-assisted work.
**Affected Area**: compliance, policies, documentation, wiki, changelog
**PR Reference**: pending pull request for `fix/v3-ai-accountability-no-attribution`
**Task Reference**: FAE-GOV-2026-05-11-012
**Approval Class**: governance-class
**breaking_change**: true
**migration_note**: Consumers that process FAE-C012 must require a human accountable owner, acting governed role, contract ID or remediation phase ID, review evidence, validation evidence, and required approval evidence, and must reject attribution credit to tools, models, vendors, automation, or agents on governed delivery surfaces.
**Migration Guidance**: Update contract templates, review checklists, validator integrations, changelog and release review procedures, and PR review practices that evaluate FAE-C012 so they distinguish accountability evidence from attribution credit. Do not record tool, model, vendor, automation, or agent names as authors, contributors, reviewers, validators, approvers, releasers, maintainers, or sources of work.
**Affected Consumers**: Contract authors, validators, documentation reviewers, release reviewers, policy manifest consumers, downstream repositories that mirror Forsetti policy JSON, and optional adapters or checks that evaluate FAE-C012.

**Title**: Breaking: Encode policy path, documentation, changelog, and release gates
**Change Class**: breaking-change
**Version Impact**: major
**Summary**: Updated repository boundary, documentation sync, changelog, and versioning manifests with enforceable rule identifiers, pre-merge gate metadata, required evidence, rejection conditions, and byte-identical root mirror metadata. Contract-mode validation now consumes the boundary manifest for protected and role-limited path checks, consumes the docs sync manifest for changed canonical source checks, validates changelog entries against task contract fields, and reports policy rule, condition, and gate identifiers in validator findings.
**Affected Area**: policies, core validator, validator result schema, documentation, changelog
**PR Reference**: pending pull request for `fix/v3-policy-paths-docs-release`
**Task Reference**: FAE-GOV-2026-05-10-008
**Approval Class**: governance-class
**breaking_change**: true
**migration_note**: Consumers of machine-readable policy manifests must accept `schema_version` 2.0 for docs sync, changelog, and versioning rules, `schema_version` 2.1 for repository boundary rules, root mirror metadata, pre-merge gate arrays, rule IDs, gate IDs, evidence requirements, and rejection condition fields. Consumers of validator result JSON must accept `policy_rule_id`, `condition_id`, and `gate_id` fields on each finding.
**Migration Guidance**: Update policy-manifest parsers to treat `core/policies/*.json` as canonical where root mirrors exist and to preserve unknown structured gate metadata. Update validator-result consumers to read the added finding fields and to tolerate policy-local rule IDs alongside canonical `FAE-C###` compliance rule IDs. Update pre-merge integrations to enforce changelog entries under `Unreleased`, required breaking-change migration fields, affected consumers, version impact consistency, and docs sync for changed canonical sources.
**Affected Consumers**: Local validator integrations, hosted workflow adapters, policy manifest parsers, documentation sync reviewers, changelog and release reviewers, downstream repositories that mirror Forsetti policy JSON, and tools that parse `core/schemas/validator-result.schema.json`.

**Title**: Breaking: Enforce task contract scope, approval, and evidence locally
**Change Class**: breaking-change
**Version Impact**: major
**Summary**: Added an enforceable task contract schema under `core/schemas/`, a JSON task contract template under `core/contracts/`, contract enforcement rules under `core/validator/`, and validator CLI inputs for contract path and changed-file evidence. Contract mode now checks required contract fields, changed-file scope, protected-path approval class, required outputs, documentation impact, changelog impact, and evidence artifacts.
**Affected Area**: contracts, schemas, core validator, scripts, documentation, changelog
**PR Reference**: pending pull request for `fix/v3-contract-enforcement`
**Task Reference**: FAE-GOV-2026-05-10-007
**Approval Class**: governance-class
**breaking_change**: true
**migration_note**: Consumers that validate task contracts must accept the date-stamped task ID format such as `FAE-GOV-2026-05-10-007`, the new `scope` object with `in_scope` and `out_of_scope`, `evidence_requirements`, `required_advisory_reviewers`, `governance_authorization`, and `documentation_impact.changelog_update`. Consumers that call the local validator should use `-Mode contract` with `-ContractPath` and explicit changed-file input through `-ChangedFile` or `-ChangedFilesPath` when enforcing a specific task contract.
**Migration Guidance**: Update task-contract producers to emit the schema fields in `core/schemas/task-contract.schema.json`. Update validator consumers to tolerate `contract`, `scope`, `approval`, `changelog`, and `evidence` finding categories and the added invocation metadata fields in `core/schemas/validator-result.schema.json`.
**Affected Consumers**: Contract authors, validator integrations, release reviewers, documentation reviewers, scripts that parse validator results, and downstream repositories that consume `schemas/task-contract.schema.json` or `core/schemas/validator-result.schema.json`.

**Title**: Breaking: Establish canonical compliance rule registry
**Change Class**: breaking-change
**Version Impact**: major
**Summary**: Established `core/policies/compliance-rules.json` as the canonical registry for `FAE-C001` through `FAE-C012`, mirrored the compatibility registry at `policies/compliance-rules.json`, aligned repository boundary manifests, and updated policy and wiki references so Markdown and JSON use the same compliance rule meanings.
**Affected Area**: compliance, policies, core, documentation, changelog, contracts
**PR Reference**: pending pull request for `fix/v3-canonical-policy-registry`
**Task Reference**: FAE-GOV-2026-05-08-005
**Approval Class**: governance-class
**breaking_change**: true
**migration_note**: Consumers that referenced old Markdown rule meanings must update to the canonical registry: `FAE-C003` is Role Separation Enforcement, `FAE-C004` is Protected Asset Governance Gate, `FAE-C005` is Changelog Entry Required for Substantive Changes, `FAE-C006` is Breaking Change Disclosure Mandate, `FAE-C007` is Completion Summary Truthfulness, `FAE-C008` is Documentation Sync Compliance, `FAE-C009` is Version Classification Accuracy, `FAE-C010` is Governance Change Isolation, `FAE-C011` is Evidence and Validation Integrity, and `FAE-C012` is AI Assistance Accountability and Non-Attribution.
**Migration Guidance**: Consumers that referenced old Markdown rule meanings must update to the canonical registry: `FAE-C003` is Role Separation Enforcement, `FAE-C004` is Protected Asset Governance Gate, `FAE-C005` is Changelog Entry Required for Substantive Changes, `FAE-C006` is Breaking Change Disclosure Mandate, `FAE-C007` is Completion Summary Truthfulness, `FAE-C008` is Documentation Sync Compliance, `FAE-C009` is Version Classification Accuracy, `FAE-C010` is Governance Change Isolation, `FAE-C011` is Evidence and Validation Integrity, and `FAE-C012` is AI Assistance Accountability and Non-Attribution.
**Affected Consumers**: Validators, policy readers, documentation sync checks, workflow adapters, contract authors, and release reviewers that consume compliance rule identifiers or policy manifests.

### Governance

**Title**: Protect GitHub Actions adapter workflow scripts
**Change Class**: governance
**Version Impact**: governance-only
**Summary**: Updated the repository boundary manifest so future `adapters/github-actions/workflows/**` scripts are protected, role-limited to Architect or Governance Steward authority, and require sensitive approval or higher before merge. This prevents Phase 06 from moving hosted enforcement logic into an under-protected adapter path.
**Affected Area**: policies, adapters, workflows, documentation, changelog
**PR Reference**: pending pull request for `fix/v3-adapter-workflow-boundary-protection`
**Task Reference**: FAE-GOV-2026-05-11-009
**Approval Class**: governance-class

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
