# Changelog

> **Canonical source**: `changelog/CHANGELOG.md`
> **Last synced**: 2026-05-08, Phase 01 portable scaffold

All notable changes to the Forsetti Agentic Edition governance framework are documented in the canonical changelog.

## [Unreleased]

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
