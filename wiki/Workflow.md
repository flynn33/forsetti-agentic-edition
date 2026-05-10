# Workflow

> **Canonical sources**: [`AGENTS.md`](https://github.com/flynn33/forsetti-agentic-edition/blob/main/AGENTS.md), [`CHANGE_CONTROL_POLICY.md`](https://github.com/flynn33/forsetti-agentic-edition/blob/main/CHANGE_CONTROL_POLICY.md)
> **Last synced**: 2026-05-10, FAE-GOV-2026-05-10-008 policy paths, docs, changelog, and release accuracy

[![Version](https://img.shields.io/badge/version-v1.0.0-blue)](https://github.com/flynn33/forsetti-agentic-edition) [![License](https://img.shields.io/badge/license-see%20repo-lightgrey)](https://github.com/flynn33/forsetti-agentic-edition/blob/main/LICENSE.md)

---

## Purpose

Workflow is governed by two canonical sources:

- `AGENTS.md` defines the operating sequence, role model, role boundaries, and completion summary requirements.
- `CHANGE_CONTROL_POLICY.md` defines change classes, approval classes, scope control, protected assets, and rejection conditions.

This page summarizes those sources for navigation. The repository files remain authoritative.

---

## Operating Sequence

Before meaningful work begins, the agent must identify the task, classify the change, determine whether a task contract exists or is needed, confirm the acting and reviewer roles, confirm the approval class, confirm scope, execute within that scope, update required documentation, add a changelog entry when required, produce evidence, and submit for validation.

This sequence is mandatory for meaningful changes. Work without a governing contract is not reviewable under the compliance model.

---

## Role Boundaries

Five governed roles operate in the repository:

| Role | Authority | Responsibility |
|---|---|---|
| Architect | Planning | Creates task contracts, classifies changes, and defines scope |
| Builder | Execution | Implements authorized work within contract scope |
| Validator | Verification | Reviews compliance and renders pass, request-changes, or block |
| Release Manager | Release | Confirms version classification and release readiness |
| Documentation Manager | Documentation | Reviews wiki sync, README integrity, and documentation drift |

An elevated Governance Steward authority exists for constitutional amendments and governance-class changes.

Agents must respect role boundaries. Builders do not validate their own work.

---

## Change Classes

Every meaningful change is classified before execution:

| Change Class | Use |
|---|---|
| feature | Adds a new governance capability or governed artifact |
| bugfix | Corrects an error without changing rule intent |
| refactor | Restructures content without changing meaning or enforcement |
| docs | Updates documentation without modifying policy rules |
| governance | Modifies constitutional, policy, compliance, or protected governance content |
| release | Prepares a release |
| metadata | Changes whitespace, formatting, punctuation, or non-functional settings only |
| breaking-change | Changes rules, structures, or enforcement in a way consumers must adapt to |

When classification is uncertain, the higher-risk classification is used.

---

## Approval Classes

Approval class determines the required review authority:

| Approval Class | Applies To |
|---|---|
| Standard | Routine feature, bugfix, refactor, docs, or metadata changes |
| Sensitive | Higher-risk changes affecting multiple policy areas, schemas, role instructions, or workflows |
| Governance-Class | Constitutional, compliance, policy, or protected governance changes |
| Emergency | Time-critical fixes with required post-hoc validation |
| Release-Critical | Release preparation governed by the Release Manager |

Governance-class changes require elevated handling and must not be bundled with unrelated work.

---

## Scope Control

Scope is defined by the task contract. Files outside that scope must not be modified.

If additional scope becomes necessary, the Builder must identify the need, request a contract amendment from the Architect, and wait for the amended scope before modifying the newly authorized files.

Unauthorized scope expansion is a blocking violation.

The local validator can enforce changed files against a governing task contract with `-Mode contract`, `-ContractPath`, and either `-ChangedFile` or `-ChangedFilesPath`. Contract mode also checks required outputs, evidence artifacts, documentation and changelog obligations, and protected-path approval requirements.

---

## Protected Assets

Protected assets require the approval class defined by `CHANGE_CONTROL_POLICY.md`. Examples include constitutional files, root policy documents, agent instructions, policy manifests, schemas, CODEOWNERS, and GitHub workflows.

Policy manifests under `core/policies/*.json` are canonical portable policy registries and require governance-class handling. Policy manifests under `policies/*.json` require governance-class handling when they encode constitutional, compliance, or policy rules; root files that mirror `core/policies/*.json` are compatibility mirrors and must not redefine canonical rule meaning.

Protected asset handling is enforced by `FAE-C004` in the canonical compliance registry. Role separation is enforced separately by `FAE-C003`.

Local protected-path checks use `core/policies/repo-boundaries.json` as the manifest-driven source for approval requirements. When multiple rules match a path, the most restrictive approval requirement applies.

The repository boundary manifest now includes pre-merge gate data for protected paths, role-limited paths, governance isolation, and policy mirror integrity. It also covers enforcement surfaces such as `core/validator/**`, `core/schemas/*.json`, `core/contracts/**`, `contracts/*-template.md`, `schemas/*.json`, and `scripts/**`.

Contract-mode validation also checks role-limited paths. A path can be in scope and still fail validation when the task contract acting role is not authorized for that path family.

---

## Required Delivery Evidence

A completion summary must include:

- Files changed
- Evidence of validation
- Known issues or an explicit none
- Documentation status
- Release impact
- Scope compliance

Claims of completion must match the evidence. Partial completion must be stated as partial.

---

## Rejection Conditions

A change is rejected or blocked when it lacks a task contract, modifies files outside scope, omits required documentation or changelog entries, lacks version impact classification, touches protected assets without authority, contradicts evidence, hides known failures, silently underclassifies a breaking change, or bundles governance changes with unrelated work.

---

<sub>

**Navigation**: [Home](Home) | [Constitution](Constitution) | [Agent Roles](Agent-Roles) | [Workflow](Workflow) | [Documentation](Documentation) | [Compliance](Compliance) | [Releases](Releases) | [Changelog](Changelog) | [Glossary](Glossary)

</sub>
