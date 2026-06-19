# Forsetti Agentic Edition Overview

> **Canonical source**: `README.md`
> **Last synced**: 2026-05-11, FAE-TASK-2026-05-11-013 platform overlay guidance

Forsetti Agentic Edition is a governance-only enforcement framework for coding agents that build Forsetti-compliant applications and modules.

FFAE does not implement Apple or Windows runtime behavior. It validates contracts, selected edition profiles, shared Forsetti invariants, manifest 1.1 requirements, declared capabilities, dependency direction, module isolation, public API use, and completion evidence.

It is not a runtime SDK or application framework. It is a governance layer that enforces disciplined delivery through constitutional governance, role boundaries, task contracts, compliance evidence, release traceability, and documentation integrity.

It also requires accountable human ownership and review evidence without attribution credit to tools, models, vendors, automation, or agents.

## Portable Architecture

Forsetti Agentic Edition is organized around three layers:

| Layer | Path | Purpose |
|---|---|---|
| Portable core | `core/` | Host-neutral governance doctrine, role boundaries, contract concepts, evidence requirements, canonical policy registries, and local validation interfaces. |
| Adapters | `adapters/` | Optional host integrations that translate local or hosted platform context into portable validation inputs. |
| Overlays | `overlays/` | Host-neutral and platform-specific execution guidance that preserves core governance meaning while documenting local expectations. |

GitHub Actions support is an optional adapter surface under `adapters/github-actions/`. It does not define canonical compliance rules. Workflow files under `.github/workflows/` are thin hosted wrappers that preserve check names and delegate implementation to scripts in `adapters/github-actions/workflows/`.

The overlay profiles under `overlays/generic/`, `overlays/forsetti-apple/`, and `overlays/forsetti-windows/` document host-neutral, Apple-platform, and Windows-native execution guidance. They do not amend compliance outcomes, task contract requirements, validator behavior, or role authority.

## Core Documents

Authority flows downward:

| Rank | Document(s) | Authority |
|---|---|---|
| 1 | `FORSETTI_CONSTITUTION.md` | Highest authority. |
| 2 | Policy documents | Binding operational policy. |
| 3 | `standards/*.md` | Operational standards. |
| 4 | `contracts/*.md` | Task contract templates and task contracts. |
| 5 | `core/policies/*.json`, `policies/*.json` | Machine-readable policy manifests. `core/policies/` contains canonical portable registries where present; matching root `policies/` files are compatibility mirrors unless a higher-authority policy says otherwise. |
| 6 | `agents/*.md` | Role-specific instructions. |
| 7 | `wiki/*.md` | Derived summary content. Not canonical. |

Portable documents under `core/`, `adapters/`, and `overlays/` are subordinate documentation surfaces introduced for portability, except for canonical portable policy registries explicitly designated under `core/policies/`. They do not amend the constitutional authority hierarchy.

`AI_ASSISTANCE_POLICY.md` supports `COMPLIANCE_POLICY.md` by defining FAE-C012 accountability and non-attribution requirements.

## Local Validation

The portable core includes a local validator at `core/validator/forsetti_validate.ps1`. Root scripts under `scripts/` delegate to that validator.

The validator supports repository structure, JSON, policy mirror, documentation sync, schema, script wrapper, and task contract checks. Contract mode enforces changed files against the governing task contract scope, checks protected-path and role-limited path requirements from `core/policies/repo-boundaries.json`, verifies required outputs and evidence artifacts, checks documentation sync for changed canonical sources, and validates changelog entries for required fields, migration guidance, affected consumers, Unreleased placement, and version consistency.

## Repository Structure

The repository now includes:

- `core/` for portable governance documents and canonical policy manifests.
- `core/contracts/task-contract-template.json` and `core/schemas/task-contract.schema.json` for enforceable task contract structure.
- `core/validator/contract_rules.ps1` for local task contract, protected path, documentation sync, changelog, and version evidence enforcement.
- `adapters/github-actions/` for optional GitHub Actions integration documentation and workflow adapter scripts.
- `overlays/generic/`, `overlays/forsetti-apple/`, and `overlays/forsetti-windows/` for platform overlay guidance profiles.
- Root governance, policy, standards, contracts, schemas, scripts, changelog, and wiki documentation.

## Operating Model

Every meaningful change must operate under a task contract, remain within authorized scope, update required documentation, include changelog evidence when required, and provide validation evidence before completion is claimed. Canonical compliance rule identifiers are defined in `core/policies/compliance-rules.json` and mirrored at `policies/compliance-rules.json`. Policy-local gate identifiers in the boundary, documentation sync, changelog, and versioning manifests provide additional evidence traceability.

## Navigation

[Home](Home) | [Constitution](Constitution) | [Agent Roles](Agent-Roles) | [Workflow](Workflow) | [Compliance](Compliance) | [Releases](Releases) | [Changelog](Changelog) | [Glossary](Glossary)
