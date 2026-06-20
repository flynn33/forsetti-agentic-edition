# Compliance

[![Decision](https://img.shields.io/badge/decision-pass%20%7C%20request%20changes%20%7C%20block-0f766e)](Compliance)
[![Compliance](https://img.shields.io/badge/FAE--C-12%20rules-2563eb)](Compliance)
[![Forsetti](https://img.shields.io/badge/FAE--F-20%20rules-7c3aed)](Compliance)

> **Canonical sources**: [`COMPLIANCE_POLICY.md`](https://github.com/flynn33/forsetti-agentic-edition/blob/main/COMPLIANCE_POLICY.md), `core/policies/compliance-rules.json`, `core/policies/forsetti-enforcement-rules.json`, `core/policies/accountability-rules.json`

---

## Decision Lattice

```mermaid
%%{init: {"theme":"base","themeVariables":{"primaryColor":"#111827","primaryTextColor":"#ffffff","primaryBorderColor":"#a78bfa","lineColor":"#475569","secondaryColor":"#f5f3ff","tertiaryColor":"#ecfeff"}}}%%
flowchart TB
    Claim["Completion or compliance claim"] --> Evidence{"Evidence present?"}
    Evidence -->|no| Block["BLOCK"]
    Evidence -->|yes| Scope{"Scope and authority valid?"}
    Scope -->|no| Block
    Scope -->|yes| Context{"Forsetti context complete?"}
    Context -->|no| Block
    Context -->|yes| Profile{"Edition profile valid?"}
    Profile -->|no| Block
    Profile -->|yes| Manifest{"Manifest, capability, runtime evidence valid?"}
    Manifest -->|no| Block
    Manifest -->|yes| Docs{"Docs, changelog, version impact aligned?"}
    Docs -->|no| Request["REQUEST CHANGES"]
    Docs -->|yes| Findings{"Blocking findings open?"}
    Findings -->|yes| Block
    Findings -->|no| Pass["PASS"]
```

---

## Rule Family Map

| Family | Range | Count | Governs | Typical Result |
|---|---:|---:|---|---|
| Core compliance | `FAE-C001` - `FAE-C012` | 12 | contracts, scope, roles, protected assets, changelog, evidence, release integrity, documentation, accountability | request changes or block |
| Forsetti enforcement | `FAE-F001` - `FAE-F020` | 20 | project context, edition profiles, manifests, capability use, runtime requirements, module isolation, public API use, dependency direction, verification evidence | block when invariants fail |
| Policy gates | policy-local IDs | varies | PR templates, path protection, version impact, docs sync, changelog fields | request changes or block |
| Native product checks | command condition IDs | command-local | bundle integrity, init, doctor, discovery, version reporting | pass, request changes, block, or integrity failure |

---

## Core Compliance Rule Matrix

| Rule | Title | Product Meaning |
|---|---|---|
| `FAE-C001` | Task Contract Required Before Execution | Meaningful work must begin from an explicit governed contract. |
| `FAE-C002` | Scope Boundary Enforcement | Changed files and behavior must stay inside approved scope. |
| `FAE-C003` | Role Separation Enforcement | Planning, building, validation, release, and documentation authority cannot collapse into one unchecked role. |
| `FAE-C004` | Protected Asset Governance Gate | Protected paths require the correct approval class and reviewer path. |
| `FAE-C005` | Changelog Entry Required for Substantive Changes | Meaningful product, policy, docs, release, or governance changes must be traceable. |
| `FAE-C006` | Breaking Change Disclosure Mandate | Breaking changes require migration notes and affected consumers. |
| `FAE-C007` | Completion Summary Truthfulness | Completion claims must match actual code, docs, tests, and limitations. |
| `FAE-C008` | Documentation Sync Compliance | Canonical and derived docs must remain aligned or carry an approved deferral. |
| `FAE-C009` | Version Classification Accuracy | Version impact must match actual consumer impact. |
| `FAE-C010` | Governance Change Isolation | Governance changes must not hide unrelated behavior changes. |
| `FAE-C011` | Evidence and Validation Integrity | Validation evidence must be real, current, and accurately reported. |
| `FAE-C012` | Accountability and Non-Attribution | Human accountability is required; attribution credit to tools or automation is prohibited. |

---

## Forsetti Enforcement Rule Matrix

| Rule | Title | Blocking Condition |
|---|---|---|
| `FAE-F001` | Forsetti project context required | Target work starts without required repository mode, edition, platform, version, manifest, capability, runtime, or API-boundary context. |
| `FAE-F002` | Edition/version profile required | No selected Apple, Windows, or shared profile is available for validation. |
| `FAE-F003` | Target platform must match edition profile | Target platform is outside the selected profile. |
| `FAE-F004` | Valid Forsetti manifest required | Manifest is absent, malformed, or not schema/template `1.1` where required. |
| `FAE-F005` | Manifest/code identity match required | Manifest identity does not match the target module or code surface. |
| `FAE-F006` | Module isolation required | Module boundaries are crossed directly. |
| `FAE-F007` | Direct module dependency prohibited | Governed modules depend on each other directly. |
| `FAE-F008` | Direct module data sharing prohibited | Modules share data outside approved public contracts. |
| `FAE-F009` | Declared capability required before use | Code uses a capability not declared in the manifest. |
| `FAE-F010` | Runtime requirements required for I/O/UI/data isolation | Runtime requirements are absent or incomplete. |
| `FAE-F011` | Public Forsetti API only | Consumer code reaches beyond public products. |
| `FAE-F012` | Sealed framework internals protected | Framework internals are patched or referenced directly. |
| `FAE-F013` | One-way dependency direction required | Core/platform/host dependency direction is inverted. |
| `FAE-F014` | UI/app active surface invariant required | UI/app modules lack the active surface requirement. |
| `FAE-F015` | Service module UI contribution prohibited | Service modules attempt to contribute UI. |
| `FAE-F016` | Constructor dependency injection required | Dependencies are hidden or created outside the governed contract. |
| `FAE-F017` | Hidden globals/service-location prohibited | Hidden global state or service-location bypasses the boundary. |
| `FAE-F018` | Platform-native toolchain required | Required native verification path is skipped or replaced without authorization. |
| `FAE-F019` | Required verification commands must run | Profile-required verification is absent or inaccurately reported. |
| `FAE-F020` | Completion evidence must map to selected edition profile | Evidence does not prove the selected profile obligations. |

---

## Enforcement Coverage Diagram

```mermaid
%%{init: {"theme":"base","themeVariables":{"primaryColor":"#1e293b","primaryTextColor":"#ffffff","primaryBorderColor":"#f87171","lineColor":"#991b1b","secondaryColor":"#fef2f2","tertiaryColor":"#f8fafc"}}}%%
flowchart LR
    Contract["Contract"] --> C001["FAE-C001"]
    Scope["Changed files"] --> C002["FAE-C002"]
    Roles["Role activity"] --> C003["FAE-C003"]
    Protected["Protected paths"] --> C004["FAE-C004"]
    Changelog["Changelog"] --> C005["FAE-C005"]
    Version["Version impact"] --> C009["FAE-C009"]
    Docs["Docs/wiki"] --> C008["FAE-C008"]
    Evidence["Validation proof"] --> C011["FAE-C011"]
    Accountability["Accountability record"] --> C012["FAE-C012"]

    Context["Project context"] --> F001["FAE-F001"]
    Profile["Edition profile"] --> F002["FAE-F002/F003"]
    Manifest["Module manifest"] --> F004["FAE-F004/F005"]
    Capabilities["Capability use"] --> F009["FAE-F009"]
    Runtime["Runtime requirements"] --> F010["FAE-F010"]
    Boundaries["Module/API boundaries"] --> F006["FAE-F006-F013"]
    Verify["Profile verification"] --> F019["FAE-F019"]
    Completion["Completion evidence"] --> F020["FAE-F020"]
```

---

## Decision Table

| Evidence State | Scope State | Rule State | Decision |
|---|---|---|---|
| missing | any | any | block |
| present | outside scope | any | block |
| present | inside scope | protected path without approval | block |
| present | inside scope | invariant violation | block |
| present | inside scope | docs/changelog/version gap | request changes |
| present | inside scope | no unresolved required findings | pass |

---

## Native Integrity Checks

Bundle verification is the native command family that most directly maps to product integrity. Apple and Windows implementations both fail closed for missing or invalid bundle manifests, unsafe paths, missing required files, and hash mismatches.

```mermaid
%%{init: {"theme":"base","themeVariables":{"primaryColor":"#0f172a","primaryTextColor":"#ffffff","primaryBorderColor":"#fbbf24","lineColor":"#92400e","secondaryColor":"#fffbeb","tertiaryColor":"#f8fafc"}}}%%
flowchart TB
    Manifest["product-manifest.json"] --> Schema{"schema 2.0?"}
    Schema -->|no| Fail["integrity failure"]
    Schema -->|yes| Paths{"safe unique paths?"}
    Paths -->|no| Fail
    Paths -->|yes| Required{"all required files present?"}
    Required -->|no| Fail
    Required -->|yes| Hashes{"SHA-256 values match?"}
    Hashes -->|no| Fail
    Hashes -->|yes| ProductLock{"product lock present?"}
    ProductLock -->|mismatch| Fail
    ProductLock -->|missing or match| Pass["bundle verified"]
```

---

**Navigation**: [Home](Home) | [Overview](Overview) | [Workflow](Workflow) | [Agent Roles](Agent-Roles) | [Documentation](Documentation) | [Releases](Releases) | [Changelog](Changelog) | [Constitution](Constitution) | [Glossary](Glossary)
