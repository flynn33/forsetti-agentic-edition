# Releases

[![Release](https://img.shields.io/badge/release-integrity%20gate-0f766e)](Releases)
[![Version](https://img.shields.io/badge/current-v1.0.0-blue)](Changelog)
[![Impact](https://img.shields.io/badge/impact-none%20patch%20minor%20major%20governance--only-7c3aed)](Releases)

> **Canonical source**: [`RELEASE_POLICY.md`](https://github.com/flynn33/forsetti-agentic-edition/blob/main/RELEASE_POLICY.md)
> **Current version**: `v1.0.0`

---

## Current Release Snapshot

| Surface | Current State | Release Meaning |
|---|---|---|
| Repository version | `1.0.0` | No version bump has been applied after product-completion work. |
| Bundle version | `1.0.0` | Source bundle and repository version are aligned. |
| Bundle manifest | schema `2.0`, 46 required files | Product payload is hash-verifiable. |
| Apple product | Swift executable | Implements full current native command shell. |
| Windows product | C++20 executable | Implements version and bundle verification. |
| Release status | Unreleased queue contains major/minor/patch/governance entries | Future release classification must use highest included impact. |

---

## Release Gate Circuit

```mermaid
%%{init: {"theme":"base","themeVariables":{"primaryColor":"#111827","primaryTextColor":"#ffffff","primaryBorderColor":"#34d399","lineColor":"#047857","secondaryColor":"#ecfdf5","tertiaryColor":"#f8fafc"}}}%%
flowchart LR
    Change["included change"] --> Validated{"validated?"}
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
| `none` | Evidence, metadata, or presentation with no governed meaning change. | final validation evidence only | low |
| `patch` | Correction to existing content without changing policy meaning. | docs alignment, broken link, wording correction | low to moderate |
| `minor` | Additive backward-compatible capability. | new native command surface, new overlay guidance | moderate |
| `major` | Breaking schema, rule, workflow, or consumer obligation change. | required field change, new blocking enforcement | high |
| `governance-only` | Governance posture change outside normal semantic versioning. | protected path or approval-class change | high review burden |

---

## Product Release Composition

```mermaid
%%{init: {"theme":"base","themeVariables":{"pie1":"#2563eb","pie2":"#0f766e","pie3":"#f59e0b","pie4":"#dc2626","pie5":"#7c3aed","pieTitleTextSize":"18px"}}}%%
pie showData
    title Current Unreleased Impact Mix
    "none" : 1
    "patch" : 4
    "minor" : 3
    "major" : 5
    "governance-only" : 2
```

---

## Release Readiness Checklist

| Gate | Required Evidence |
|---|---|
| Version classification | release policy and versioning policy agree with highest included impact |
| Changelog completeness | each meaningful change has title, class, impact, summary, affected area, task reference, approval class |
| Breaking disclosure | breaking entries include migration note, migration guidance, and affected consumers |
| Product bundle | generated manifest matches bundle files and hashes |
| Native product checks | available Apple/Windows checks run or limitations documented |
| Documentation sync | canonical docs, repo wiki mirror, live wiki, and changelog align |
| Attribution guard | prohibited attribution/provider phrases absent |
| Release manager review | release gate evidence is explicit |

---

## Release Timeline

```mermaid
%%{init: {"theme":"base","themeVariables":{"primaryColor":"#0f172a","primaryTextColor":"#ffffff","primaryBorderColor":"#a78bfa","lineColor":"#4f46e5","secondaryColor":"#eef2ff","tertiaryColor":"#f8fafc"}}}%%
gitGraph
    commit id: "v1.0.0 foundation"
    branch remediation
    checkout remediation
    commit id: "portable core"
    commit id: "policy gates"
    commit id: "validator"
    commit id: "overlays"
    commit id: "final validation"
    checkout main
    merge remediation id: "governance remediation"
    branch product
    checkout product
    commit id: "product completion 00-05"
    checkout main
    merge product id: "PR 14"
    branch docs
    checkout docs
    commit id: "docs alignment"
    checkout main
    merge docs id: "PR 15"
```

---

## Product Surface Readiness

| Surface | Ready For | Not Yet Claimed |
|---|---|---|
| Source bundle | deterministic hash verification | published release artifact packaging beyond source tree |
| Apple CLI | version, bundle verification, init, doctor, discover | downstream runtime behavior |
| Windows CLI | version, bundle verification | init, doctor, discover parity |
| PowerShell validator | repository and target validation modes | running without a PowerShell host |
| Live wiki | public orientation and visual documentation | canonical authority over source files |

---

**Navigation**: [Home](Home) | [Overview](Overview) | [Workflow](Workflow) | [Compliance](Compliance) | [Agent Roles](Agent-Roles) | [Documentation](Documentation) | [Changelog](Changelog) | [Constitution](Constitution) | [Glossary](Glossary)
