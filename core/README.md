# Portable Core

The portable core contains host-neutral Forsetti Agentic Edition governance concepts. It defines the delivery model that adapters and overlays consume, without depending on a hosting platform, workflow runner, IDE, local MCP server, browser, container runtime, or provider-specific tool.

## Purpose

The core exists to make Forsetti governance portable across repositories and execution environments. It describes the invariant rules and interfaces that must remain stable while platform adapters and overlays handle local differences.

## Core Boundaries

The core owns:

- contract-first execution
- role authority boundaries
- scope binding
- Forsetti project context requirements
- edition profile selection
- manifest, capability, runtime requirement, dependency, module-isolation, and public API enforcement concepts
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

The portable core now contains concrete policy, schema, contract, validator, and authority-model files. These interfaces are stable repository-local surfaces for adapters, overlays, and native products to consume without making those host layers part of the core.

| Interface | Purpose |
|---|---|
| `TaskContract` | `core/schemas/task-contract.schema.json` and `core/contracts/task-contract-template.json` define scope, change class, approval class, required outputs, validation gates, and completion evidence. |
| `ProjectContext` | `core/schemas/forsetti-project-context.schema.json` defines the required Forsetti edition, platform, version, module, capability, runtime, and public API context for governed target work. |
| `ModuleManifest` | `core/schemas/module-manifest-1.1.schema.json` defines the current manifest 1.1 contract used by target module checks. |
| `PolicyRegistry` | `core/policies/*.json` provides canonical rule identifiers, severities, evidence requirements, gate metadata, and remediation guidance. |
| `ValidationResult` | `core/schemas/validator-result.schema.json` reports pass, request-changes, or block decisions with findings, evidence paths, and unresolved issues. |
| `Validator` | `core/validator/forsetti_validate.ps1` and supporting rule files execute repository and target checks from repository-local inputs. |
| `AuthorityModel` | `core/enforcement/authority-model.md` documents role authority and enforcement boundaries consumed by documentation and review surfaces. |
| `Adapter` | Optional adapters translate host-specific context into portable validation inputs without becoming canonical compliance authorities. |
| `Overlay` | Overlays narrow local execution guidance without changing core governance meaning. |

## Dependency Direction

Adapters and overlays depend on the core. The core does not depend on adapters or overlays.

```text
adapters/*  -> core
overlays/*  -> core
core        -> no adapters, no overlays, no hosted workflow dependency
```

## Policy Registry Files

Current host-neutral policy manifests under `core/policies/`:

| File | Purpose |
|---|---|
| `core/policies/accountability-rules.json` | Canonical support policy for accountability and non-attribution. |
| `core/policies/agent-enforcement-actions.json` | Enforcement action mapping for governed roles and rule outcomes. |
| `core/policies/forsetti-enforcement-rules.json` | Canonical registry for `FAE-F001` through `FAE-F020`. |
| `core/policies/manifest-rules.json` | Manifest 1.1 enforcement summary. |
| `core/policies/runtime-requirement-rules.json` | Runtime requirement enforcement summary. |
| `core/policies/module-isolation-rules.json` | Module isolation enforcement summary. |
| `core/policies/dependency-boundary-rules.json` | Dependency direction enforcement summary. |
| `core/policies/public-api-rules.json` | Public API boundary enforcement summary. |
| `core/policies/capability-rules.json` | Capability declaration enforcement summary. |
| `core/policies/mcp-provider-policy.json` | Local tool provider governance. |
| `core/policies/mcp-resolution-order.json` | Resolution order for governed local tool provider selection. |
| `core/policies/service-access-rules.json` | Service access and service role enforcement summary. |
| `core/policies/ui-contribution-rules.json` | UI contribution and module role enforcement summary. |
| `core/policies/compliance-rules.json` | Canonical registry for `FAE-C001` through `FAE-C012`. |
| `core/policies/repo-boundaries.json` | Portable repository boundary and approval-class manifest. |
| `core/policies/docs-sync-rules.json` | Portable copy of documentation sync requirements. |
| `core/policies/versioning-rules.json` | Portable copy of version impact rules. |
| `core/policies/changelog-rules.json` | Portable copy of changelog entry requirements. |

The matching root files under `policies/` are compatibility mirrors and must remain byte-for-byte identical to their `core/policies/` counterparts until a future governance change amends the hierarchy.

## Local Validator

The PowerShell-native validator lives at `core/validator/forsetti_validate.ps1` with result shape defined by `core/schemas/validator-result.schema.json`.

Contract enforcement uses `core/validator/contract_rules.ps1`, target Forsetti project checks use `core/validator/rules/forsetti_project_rules.ps1`, the canonical task contract schema lives at `core/schemas/task-contract.schema.json`, and the JSON task contract template lives at `core/contracts/task-contract-template.json`.

The root validation scripts delegate to the core validator. The validator runs from repository files and canonical policy manifests. `-Mode all` remains usable without a task contract, while `-Mode contract` requires a contract path and a changed-file set or local git status inference.

Enforceable gate metadata exists in the boundary, documentation sync, changelog, and versioning manifests. Contract mode consumes the boundary manifest for protected and role-limited paths, consumes the docs sync manifest for same-change derived documentation checks, and checks changelog entries against the task contract before merge.

The canonical support manifest for accountability and non-attribution is `core/policies/accountability-rules.json`.

The current validator supports `repo`, `contract`, `project-context`, `edition-profile`, `manifest`, `dependencies`, `capabilities`, `module-isolation`, `evidence`, and `all` modes. These modes let FFAE validate itself and target Forsetti app/module repositories without requiring hosted workflows.

Platform overlay guidance lives under `overlays/generic/`, `overlays/forsetti-apple/`, and `overlays/forsetti-windows/`. Those overlays narrow local evidence expectations for host-neutral, Apple-platform, and Windows-native work while remaining dependent on the portable core.

## Current Status

This directory contains canonical compliance and Forsetti enforcement registries, portable policy manifests with pre-merge gate metadata, the accountability manifest, local validator CLI, task and target schemas, task contract JSON template, contract enforcement rules, target project rules, and authority-model documentation. Optional adapters, platform overlays, source bundles, and native products use the core as their governance base; the core does not depend on adapter scripts, overlay documents, product hosts, hosted workflows, IDEs, local MCP servers, browser automation, container runtimes, or provider-specific tooling.
