# Releases

[![Release](https://img.shields.io/badge/release-integrity%20gate-0f766e)](Releases) [![Version](https://img.shields.io/badge/current-v1.0.0-blue)](Changelog) [![Impact](https://img.shields.io/badge/impact-none%20patch%20minor%20major%20governance--only-7c3aed)](Releases)

> **Canonical source**: [`RELEASE_POLICY.md`](https://github.com/flynn33/forsetti-agentic-edition/blob/main/RELEASE_POLICY.md)
> **Current version**: `v1.0.0`

---

## Release Gate Circuit

```mermaid
%%{init: {"theme":"base","themeVariables":{"primaryColor":"#111827","primaryTextColor":"#ffffff","primaryBorderColor":"#34d399","lineColor":"#047857","secondaryColor":"#ecfdf5","tertiaryColor":"#f8fafc"}}}%%
flowchart LR
    Change["Included change"] --> Validated{"validated?"}
    Validated -->|no| Stop["release stops"]
    Validated -->|yes| Changelog{"changelog complete?"}
    Changelog -->|no| Stop
    Changelog -->|yes| Version{"version impact accurate?"}
    Version -->|no| Stop
    Version -->|yes| Docs{"documentation synchronized?"}
    Docs -->|no| Stop
    Docs -->|yes| Blocking{"blocking violations open?"}
    Blocking -->|yes| Stop
    Blocking -->|no| Ready["release ready"]
```

---

## Version Impact Matrix

| Impact | Meaning | Typical Use | Release Risk |
|---|---|---|---|
| `none` | Presentation, metadata, or formatting with no governed meaning change. | Cosmetic wiki refresh, typo that does not alter meaning. | Low, but still review for drift. |
| `patch` | Correction to existing content without changing policy meaning. | Broken link, schema validation repair, wording fix. | Low to moderate. |
| `minor` | Additive capability or clarification that remains backward compatible. | New guidance profile, new non-breaking template. | Moderate. |
| `major` | Breaking rule, schema, workflow, or consumer obligation change. | Required field change, enforcement behavior change. | High. |
| `governance-only` | Governance posture change that does not map cleanly to semantic versioning. | Protected-path policy, approval-class adjustment. | High review burden. |

---

## Product Surface Snapshot

| Surface | Current State | Release Note |
|---|---|---|
| Repository version | `1.0.0` | No version bump has been applied after the merged product-completion work. |
| Source bundle | `bundle/product-manifest.json` schema `2.0`, 46 required entries | Bundle integrity is verified by native product command surfaces. |
| Apple product | `forsetti-governance` Swift executable | Implements `version`, `bundle verify`, `init`, `doctor`, and `discover`. |
| Windows product | `forsetti-governance` C++20 executable | Implements `version` and `bundle verify`. |

---

## Breaking-Change Path

```mermaid
%%{init: {"theme":"base","themeVariables":{"primaryColor":"#1e293b","primaryTextColor":"#ffffff","primaryBorderColor":"#f87171","lineColor":"#991b1b","secondaryColor":"#fef2f2","tertiaryColor":"#f8fafc"}}}%%
sequenceDiagram
    participant Architect
    participant Builder
    participant Validator
    participant Release as Release Manager
    participant Steward as Governance Steward

    Architect->>Architect: classify breaking impact
    Architect->>Builder: issue contract with migration requirements
    Builder->>Builder: update implementation, docs, changelog
    Builder->>Validator: submit evidence and affected consumers
    Validator->>Release: confirm rule, schema, and docs impact
    Release->>Steward: request required elevated approval
    Steward-->>Release: explicit approval or rejection
```

---

## Required Changelog Fields

| Field | Purpose |
|---|---|
| `title` | Names the change in reviewable language. |
| `change_class` | Classifies feature, bugfix, docs, governance, release, metadata, or breaking-change work. |
| `version_impact` | Records semantic or governance impact. |
| `summary` | States what changed and why. |
| `affected_area` | Identifies touched governance areas. |
| `task_reference` | Links the change to its authorizing task. |
| `approval_class` | Records the required authority path. |
| `migration_guidance` | Required for breaking changes. |
| `affected_consumers` | Required for breaking changes. |

---

## Batch Release Rule

```mermaid
%%{init: {"theme":"base","themeVariables":{"primaryColor":"#0f172a","primaryTextColor":"#ffffff","primaryBorderColor":"#a78bfa","lineColor":"#4f46e5","secondaryColor":"#eef2ff","tertiaryColor":"#f8fafc"}}}%%
flowchart TB
    Batch["Batch release"] --> C1["each change has its own changelog entry"]
    Batch --> C2["each change has validation evidence"]
    Batch --> C3["aggregate impact is highest individual impact"]
    Batch --> C4["one non-compliant change blocks the batch"]
```

---

<details>
<summary><strong>Release Manager Boundary</strong></summary>

The Release Manager confirms version impact, changelog integrity, readiness, and release mechanics. The role does not waive compliance gates, override blocking violations, alter policy content during release preparation, or reclassify breaking changes to reduce review burden.

</details>

---

**Navigation**: [Home](Home) | [Overview](Overview) | [Workflow](Workflow) | [Compliance](Compliance) | [Agent Roles](Agent-Roles) | [Documentation](Documentation) | [Changelog](Changelog) | [Glossary](Glossary)
