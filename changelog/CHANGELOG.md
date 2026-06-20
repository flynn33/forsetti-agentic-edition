# Changelog

All notable changes to the Forsetti Agentic Edition governance framework are documented in this file.

The changelog is a governance record. Entries must be accurate, specific, and traceable.

## [Unreleased]

### Breaking Changes

**Title**: Breaking: Canonicalize accountability policy surfaces
**Change Class**: breaking-change
**Version Impact**: major
**Summary**: Removed obsolete duplicate accountability policy names and manifests so `ACCOUNTABILITY_POLICY.md` and `core/policies/accountability-rules.json` are the canonical no-attribution accountability surfaces, with the root policy mirror kept byte-identical.
**Affected Area**: compliance, policies, documentation sync, contracts, changelog
**PR Reference**: PR #13, merge commit `a70bc6545de90d465e7b1ab4f760b1f93acc86c8`
**Task Reference**: FAE-GOV-2026-05-11-012
**Approval Class**: governance-class
**breaking_change**: true
**migration_note**: Consumers that referenced the removed duplicate accountability policy file or manifest paths must switch to `ACCOUNTABILITY_POLICY.md`, `core/policies/accountability-rules.json`, and `policies/accountability-rules.json`.
**Migration Guidance**: Update documentation sync manifests, policy manifest consumers, task contracts, validators, and review checklists to read the canonical accountability policy and accountability-rules manifests. Remove references to the obsolete duplicate accountability policy filename and manifest filenames.
**Affected Consumers**: Policy manifest consumers, documentation sync reviewers, task contract authors, validators, release reviewers, and downstream repositories that mirror Forsetti accountability policy paths.

**Title**: Breaking: Add Forsetti edition-profile enforcement
**Change Class**: breaking-change
**Version Impact**: major
**Summary**: Added Forsetti project context requirements, Apple and Windows edition profiles, shared sealed-runtime invariants, manifest 1.1 schema validation, Forsetti enforcement rules `FAE-F001` through `FAE-F020`, and local validator modes for profile, manifest, dependency, capability, module-isolation, and evidence checks.
**Affected Area**: core schemas, core policies, edition profiles, task contracts, validator, agents, overlays, wiki, standards
**PR Reference**: PR #11, merge commit `1d380a1d4c640d0b5a0e14cadcf076e283347365`
**Task Reference**: FFAE-GOVERNANCE-ENFORCEMENT-REMEDIATION
**Approval Class**: governance-class
**breaking_change**: true
**migration_note**: Consumers that create or validate FFAE task contracts must now provide Forsetti project context before app/module execution and must map completion evidence to the selected Apple or Windows edition profile. Validator consumers must accept the new target-repository modes and `FAE-F###` findings.
**Migration Guidance**: Update contract producers to include `forsetti_project_context`, select an edition profile from `editions/`, provide manifest 1.1 evidence where applicable, declare capability and runtime requirement evidence, and run the local validator modes that match the changed files.
**Affected Consumers**: Task contract authors, local validator integrations, hosted workflow adapters, documentation reviewers, release reviewers, downstream repositories that adopt FFAE for Forsetti app/module governance.

### Release

**Title**: Record final validation acceptance audit
**Change Class**: release
**Version Impact**: none
**Summary**: Added Phase 09 final validation, regression, readiness, and acceptance audit evidence for the v3 remediation package without changing framework behavior, policy meaning, schema shape, workflow behavior, or consumer obligations.
**Affected Area**: remediation evidence, release readiness
**PR Reference**: PR #10, merge commit `7c58ecce0f8371c7b0d4d5433590135fe864ddc7`
**Task Reference**: FAE-TASK-2026-05-12-014
**Approval Class**: release-critical

### Documentation

**Title**: Align repository documentation with current product state
**Change Class**: docs
**Version Impact**: patch
**Summary**: Updated README, core documentation, wiki summary pages, release/changelog summaries, and conformance fixture documentation so they match the merged source bundle, native product command surfaces, product-completion evidence, and current repository layout.
**Affected Area**: README, core documentation, wiki, changelog, tests
**PR Reference**: No PR; local documentation alignment change
**Task Reference**: Post-merge repository documentation alignment
**Approval Class**: standard

**Title**: Refresh live wiki visual system
**Change Class**: docs
**Version Impact**: patch
**Summary**: Replaced raw wiki mirrors with curated high-density navigation pages, architecture diagrams, logic-flow diagrams, decision matrices, and a durable publication adapter that syncs the repository wiki mirror to the live GitHub Wiki.
**Affected Area**: wiki, documentation sync, GitHub Actions adapter
**PR Reference**: PR #12, merge commit `0055eb23d5d311cc57fac52b1e5a79ef85aea35d`
**Task Reference**: FAE-GOV-2026-06-19-001
**Approval Class**: governance-class

**Title**: Document GitHub Actions adapter conversion
**Change Class**: docs
**Version Impact**: patch
**Summary**: Updated README, adapter guide, wiki, and release traceability documentation to describe the Phase 06A conversion of GitHub Actions workflows into optional adapter-owned scripts while keeping final Phase 06 acceptance dependent on the Phase 06B evidence.
**Affected Area**: README, adapters, wiki, changelog, remediation evidence
**PR Reference**: PR #7, merge commit `ccac86a47c49c56f2526fcbac2e2aec349e0713b`
**Task Reference**: FAE-TASK-2026-05-11-011
**Approval Class**: standard
**Phase 06A Reference**: PR #6, merge commit `0c0a2cf6fa4b99de1bd839332991ec26ba6c354e`, evidence under `.forsetti/remediation-v3/phase-06a-*`

### Features

**Title**: Add native product completion surfaces
**Change Class**: feature
**Version Impact**: minor
**Summary**: Added product-completion evidence, Swift and C++ native product surfaces, deterministic source bundle manifest generation, bundle integrity verification, Apple repository bootstrap and doctor commands, Apple project discovery, Windows version and bundle verification commands, and shared native conformance fixture scaffolding while keeping the portable core governance-only.
**Affected Area**: products, bundle, scripts, tests, core contracts, native validation, product evidence, documentation
**PR Reference**: PR #14, merge commit `16c2b453192e213837d03b68635bfa923a6d4912`
**Task Reference**: Final product completion package
**Approval Class**: release-critical

**Title**: Add platform overlay guidance profiles
**Change Class**: feature
**Version Impact**: minor
**Summary**: Expanded generic, Apple, and Windows overlays from scaffolds into guidance profiles for host-neutral operation, Apple-platform alignment, and Windows-native evidence collection while preserving portable core boundaries and avoiding product dependency on platform tooling.
**Affected Area**: overlays, README, wiki, changelog, remediation evidence
**PR Reference**: PR #9, merge commit `5c53d307a5f4c33fb95892a1091d6b4da1d6210b`
**Task Reference**: FAE-TASK-2026-05-11-013
**Approval Class**: sensitive

**Title**: Add portable local validator CLI
**Change Class**: feature
**Version Impact**: minor
**Summary**: Added a PowerShell-native local validator under `core/validator/`, a machine-readable validator result schema, and root validation wrappers that delegate to the core validator. This establishes a repository-local validation entry point for later contract, policy path, adapter, and final acceptance phases.
**Affected Area**: core, validator, schemas, scripts, documentation, changelog, contracts
**PR Reference**: No PR; repository commit `640453a`
**Task Reference**: FAE-TASK-2026-05-08-006
**Approval Class**: governance-class

### Breaking Changes

**Title**: Breaking: Establish accountability without attribution credit
**Change Class**: breaking-change
**Version Impact**: major
**Summary**: Added a compliance support policy and machine-readable manifest requiring a human accountable owner, governed role, contract or phase reference, review evidence, validation evidence, and required approval evidence while prohibiting attribution credit across governed delivery surfaces. Consumers must now collect and validate the accountability record for assisted work.
**Affected Area**: compliance, policies, documentation, wiki, changelog
**PR Reference**: PR #8, merge commit `7de0a72223c0fe062fe97a40d2f090c68e7dea9d`
**Task Reference**: FAE-GOV-2026-05-11-012
**Approval Class**: governance-class
**breaking_change**: true
**migration_note**: Consumers that process FAE-C012 must require a human accountable owner, acting governed role, contract ID or remediation phase ID, review evidence, validation evidence, and required approval evidence, and must reject attribution credit on governed delivery surfaces.
**Migration Guidance**: Update contract templates, review checklists, validator integrations, changelog and release review procedures, and PR review practices that evaluate FAE-C012 so they distinguish accountability evidence from attribution credit. Do not record implementation sources as authors, contributors, reviewers, validators, approvers, releasers, maintainers, or sources of work.
**Affected Consumers**: Contract authors, validators, documentation reviewers, release reviewers, policy manifest consumers, downstream repositories that mirror Forsetti policy JSON, and optional adapters or checks that evaluate FAE-C012.

**Title**: Breaking: Encode policy path, documentation, changelog, and release gates
**Change Class**: breaking-change
**Version Impact**: major
**Summary**: Updated repository boundary, documentation sync, changelog, and versioning manifests with enforceable rule identifiers, pre-merge gate metadata, required evidence, rejection conditions, and byte-identical root mirror metadata. Contract-mode validation now consumes the boundary manifest for protected and role-limited path checks, consumes the docs sync manifest for changed canonical source checks, validates changelog entries against task contract fields, and reports policy rule, condition, and gate identifiers in validator findings.
**Affected Area**: policies, core validator, validator result schema, documentation, changelog
**PR Reference**: PR #4, merge commit `c164ef279a8924604074ed50cdb321f0fa9f6eb9`
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
**PR Reference**: PR #3, merge commit `a1295cdaaeceee80d6f849b2b20848e70008c4e5`
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
**PR Reference**: No PR; repository commit `7825051`
**Task Reference**: FAE-GOV-2026-05-08-005
**Approval Class**: governance-class
**breaking_change**: true
**migration_note**: Consumers that referenced old Markdown rule meanings must update to the canonical registry: `FAE-C003` is Role Separation Enforcement, `FAE-C004` is Protected Asset Governance Gate, `FAE-C005` is Changelog Entry Required for Substantive Changes, `FAE-C006` is Breaking Change Disclosure Mandate, `FAE-C007` is Completion Summary Truthfulness, `FAE-C008` is Documentation Sync Compliance, `FAE-C009` is Version Classification Accuracy, `FAE-C010` is Governance Change Isolation, `FAE-C011` is Evidence and Validation Integrity, and `FAE-C012` is Accountability and Non-Attribution.
**Migration Guidance**: Consumers that referenced old Markdown rule meanings must update to the canonical registry: `FAE-C003` is Role Separation Enforcement, `FAE-C004` is Protected Asset Governance Gate, `FAE-C005` is Changelog Entry Required for Substantive Changes, `FAE-C006` is Breaking Change Disclosure Mandate, `FAE-C007` is Completion Summary Truthfulness, `FAE-C008` is Documentation Sync Compliance, `FAE-C009` is Version Classification Accuracy, `FAE-C010` is Governance Change Isolation, `FAE-C011` is Evidence and Validation Integrity, and `FAE-C012` is Accountability and Non-Attribution.
**Affected Consumers**: Validators, policy readers, documentation sync checks, workflow adapters, contract authors, and release reviewers that consume compliance rule identifiers or policy manifests.

### Governance

**Title**: Protect GitHub Actions adapter workflow scripts
**Change Class**: governance
**Version Impact**: governance-only
**Summary**: Updated the repository boundary manifest so future `adapters/github-actions/workflows/**` scripts are protected, role-limited to Architect or Governance Steward authority, and require sensitive approval or higher before merge. This prevents Phase 06 from moving hosted enforcement logic into an under-protected adapter path.
**Affected Area**: policies, adapters, workflows, documentation, changelog
**PR Reference**: PR #5, merge commit `0ed1dc9b3f86f305c3eba3de717a2245723ae1e9`
**Task Reference**: FAE-GOV-2026-05-11-009
**Approval Class**: governance-class

**Title**: Repair docs sync policy manifest paths
**Change Class**: governance
**Version Impact**: governance-only
**Summary**: Corrected `policies/docs-sync-rules.json` so documentation sync pairs reference current repository canonical sources and wiki-derived pages required by `DOCUMENTATION_POLICY.md`, including the missing documentation page, instead of stale `docs/*`, `CONSTITUTION.md`, and root `CHANGELOG.md` paths.
**Affected Area**: policies, wiki, changelog, contracts
**PR Reference**: No PR; repository commit `c11a371`
**Task Reference**: FAE-GOV-2026-05-08-004
**Approval Class**: governance-class

### Features

**Title**: Add portable core, adapter, and overlay scaffold
**Change Class**: feature
**Version Impact**: minor
**Summary**: Added the Phase 01 portable scaffold for `core/`, `adapters/`, and `overlays/` so host-neutral governance doctrine is separated from optional host integrations and platform-specific execution guidance.
**Affected Area**: core, adapters, overlays, README, wiki, changelog, contracts
**PR Reference**: No PR; repository commit `9dc9788`
**Task Reference**: FAE-TASK-2026-05-08-002
**Approval Class**: sensitive

### Bugfixes

**Title**: Fix Windows validator repository-root resolution
**Change Class**: bugfix
**Version Impact**: patch
**Summary**: Corrected `scripts/validate-repo.ps1` so it resolves the Forsetti repository root as the parent of the `scripts/` directory instead of the parent workspace. This prevents false missing-file errors and unrelated JSON parsing failures when validating from the Windows project folder.
**Affected Area**: scripts, changelog, contracts
**PR Reference**: No PR; repository commit `62cf174`
**Task Reference**: FAE-BUG-2026-05-08-001
**Approval Class**: standard

## [1.0.0] — 2026-03-16

### Initial Release

**Title**: Forsetti Agentic Edition v1.0.0 — Foundation Release
**Change Class**: feature
**Version Impact**: major
**Summary**: Initial release of the Forsetti Agentic Edition governance framework, establishing the complete governance layer for governed software delivery. Includes constitutional governance, 5 governed roles, contract-driven workflow, compliance model, release policy, documentation policy, machine-readable policy manifests, JSON validation schemas, GitHub workflow enforcement, and wiki seed layer.
**Affected Area**: All — complete framework establishment

**Included Components**:
- FORSETTI_CONSTITUTION.md — foundational governance principles and authority hierarchy
- COMPLIANCE_POLICY.md — evidence-based compliance model with 10 blocking violations
- CHANGE_CONTROL_POLICY.md — 8 change classes, 5 approval classes, scope control
- RELEASE_POLICY.md — versioning model, release readiness, batch release handling
- DOCUMENTATION_POLICY.md — canonical source rule, wiki synchronization, drift detection
- VISION.md — mission, problem statement, strategic goals
- AGENTS.md — primary agent instructions, role model, global rules
- README.md — repository identity, structure, quick start
- CONTRIBUTING.md — contributor guide with governance requirements
- CODE_OF_DELIVERY.md — delivery doctrine and anti-patterns
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
