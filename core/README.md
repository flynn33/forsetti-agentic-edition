# Portable Core

The portable core contains host-neutral Forsetti Agentic Edition governance concepts. It defines the delivery model that adapters and overlays consume, without depending on a hosting platform, workflow runner, IDE, local MCP server, browser, container runtime, or provider-specific tool.

## Purpose

The core exists to make Forsetti governance portable across repositories and execution environments. It describes the invariant rules and interfaces that must remain stable while platform adapters and overlays handle local differences.

## Core Boundaries

The core owns:

- contract-first execution
- role authority boundaries
- scope binding
- canonical compliance policy registry
- compliance evidence requirements
- release impact classification
- documentation integrity
- portable validation concepts

The core does not own:

- hosted workflow syntax
- platform-specific shell commands
- IDE configuration
- browser automation
- container orchestration
- provider-specific tool setup
- downstream application runtime behavior

## Portable Interfaces

Later implementation phases may add concrete files under this directory. Phase 01 establishes the interface names only.

| Interface | Purpose |
|---|---|
| `TaskContract` | Defines scope, change class, approval class, required outputs, validation gates, and completion evidence. |
| `PolicyRegistry` | Provides canonical rule identifiers, severities, evidence requirements, and remediation guidance. Phase 02 implements the canonical compliance registry at `core/policies/compliance-rules.json`. |
| `ValidationRequest` | Carries repository root, changed files, contract path, policy registry path, and optional environment metadata into validation. |
| `ValidationResult` | Reports pass, request-changes, or block decisions with findings, evidence paths, and unresolved issues. |
| `Adapter` | Translates host-specific context into a portable validation request. |
| `Overlay` | Narrows local execution guidance without changing core governance meaning. |

## Dependency Direction

Adapters and overlays depend on the core. The core does not depend on adapters or overlays.

```text
adapters/*  -> core
overlays/*  -> core
core        -> no adapters, no overlays, no hosted workflow dependency
```

## Policy Registry Files

Phase 02 establishes host-neutral policy manifests under `core/policies/`:

| File | Purpose |
|---|---|
| `core/policies/compliance-rules.json` | Canonical registry for `FAE-C001` through `FAE-C012`. |
| `core/policies/repo-boundaries.json` | Portable repository boundary and approval-class manifest. |
| `core/policies/docs-sync-rules.json` | Portable copy of documentation sync requirements. |
| `core/policies/versioning-rules.json` | Portable copy of version impact rules. |
| `core/policies/changelog-rules.json` | Portable copy of changelog entry requirements. |

The matching root files under `policies/` are compatibility mirrors and must remain byte-for-byte identical to their `core/policies/` counterparts until a future governance change amends the hierarchy.

## Local Validator

Phase 03 added a PowerShell-native validator at `core/validator/forsetti_validate.ps1` and a result schema at `core/schemas/validator-result.schema.json`.

Phase 04 adds enforceable contract rules at `core/validator/contract_rules.ps1`, a canonical task contract schema at `core/schemas/task-contract.schema.json`, and a JSON task contract template at `core/contracts/task-contract-template.json`.

The root validation scripts delegate to the core validator. The validator runs from repository files and canonical policy manifests. `-Mode all` remains usable without a task contract, while `-Mode contract` requires a contract path and a changed-file set or local git status inference.

Phase 05 adds enforceable gate metadata to the boundary, documentation sync, changelog, and versioning manifests. Contract mode consumes the boundary manifest for protected and role-limited paths, consumes the docs sync manifest for same-change derived documentation checks, and checks changelog entries against the task contract before merge.

## Phase 05 Status

This directory now contains the canonical compliance policy registry, portable policy manifests with pre-merge gate metadata, local validator CLI, task contract schema, task contract JSON template, and contract enforcement rules. Optional adapter conversion and overlay validation are reserved for later remediation phases.
