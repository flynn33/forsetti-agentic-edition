# Changelog

[![Ledger](https://img.shields.io/badge/changelog-governance%20ledger-111827)](Changelog) [![Unreleased](https://img.shields.io/badge/current-unreleased%20queue-f59e0b)](Changelog) [![Version](https://img.shields.io/badge/release-v1.0.0-blue)](Releases)

> **Canonical source**: [`changelog/CHANGELOG.md`](https://github.com/flynn33/forsetti-agentic-edition/blob/main/changelog/CHANGELOG.md)
> **Purpose**: visual index for release history and pending governance records.

---

## Ledger Flow

```mermaid
%%{init: {"theme":"base","themeVariables":{"primaryColor":"#111827","primaryTextColor":"#ffffff","primaryBorderColor":"#f59e0b","lineColor":"#92400e","secondaryColor":"#fffbeb","tertiaryColor":"#f8fafc"}}}%%
flowchart LR
    Task["Task reference"] --> Entry["Changelog entry"]
    Entry --> Fields["required fields"]
    Fields --> Impact["version impact"]
    Impact --> Review["release review"]
    Review --> History["release history"]
    Entry --> Drift["documentation sync"]
    Drift --> Review
```

---

## Current Unreleased Queue

| Area | Change | Impact | Review Signal |
|---|---|---|---|
| Release | Final validation acceptance audit | `none` | Evidence record only; no framework behavior change. |
| Documentation | Live wiki visual system refresh | `patch` | Curated visual pages and durable live-wiki publication from the repository mirror. |
| Documentation | GitHub Actions adapter conversion documentation | `patch` | Documentation and traceability alignment. |
| Features | Platform overlay guidance profiles | `minor` | Additive Apple, Windows, and generic guidance profiles. |
| Features | Portable local validator CLI | `minor` | New repository-local validator entry point. |
| Breaking Changes | Accountability without attribution credit | `major` | Consumers must maintain human accountability evidence and avoid attribution credit. |
| Breaking Changes | Policy path, documentation, changelog, and release gates | `major` | Consumers must accept expanded manifest and validator result fields. |
| Breaking Changes | Task contract scope, approval, and evidence enforcement | `major` | Consumers must provide richer task-contract and changed-file evidence. |
| Breaking Changes | Canonical compliance rule registry | `major` | Consumers must align rule identifiers to the machine-readable registry. |
| Governance | GitHub Actions adapter workflow protection | `governance-only` | Adapter workflow scripts require protected-path authority. |
| Governance | Documentation sync policy manifest paths | `governance-only` | Documentation sync rules point at current canonical sources. |
| Bugfixes | Windows validator repository-root resolution | `patch` | Validator root discovery corrected. |

---

## Impact Distribution

```mermaid
%%{init: {"theme":"base","themeVariables":{"pie1":"#2563eb","pie2":"#0f766e","pie3":"#f59e0b","pie4":"#dc2626","pie5":"#7c3aed","pieTitleTextSize":"18px"}}}%%
pie showData
    title Unreleased Impact Mix
    "none" : 1
    "patch" : 3
    "minor" : 2
    "major" : 4
    "governance-only" : 2
```

---

## Release History

| Version | Date | Theme | Included Surfaces |
|---|---|---|---|
| `v1.0.0` | 2026-03-16 | Foundation release | Constitution, compliance policy, change control, release policy, documentation policy, vision, role instructions, contract templates, standards, policy manifests, validation schemas, workflow enforcement, issue templates, pull request template, CODEOWNERS, labels, wiki seed pages, and guardrail scripts. |

---

## Entry Quality Bar

```mermaid
%%{init: {"theme":"base","themeVariables":{"primaryColor":"#0f172a","primaryTextColor":"#ffffff","primaryBorderColor":"#38bdf8","lineColor":"#2563eb","secondaryColor":"#eff6ff","tertiaryColor":"#f8fafc"}}}%%
flowchart TB
    Entry["Changelog entry"] --> Specific["specific"]
    Entry --> Traceable["traceable"]
    Entry --> Classified["classified"]
    Entry --> Complete["complete"]
    Entry --> Synchronized["docs synchronized"]
    Specific --> Ready["release-reviewable"]
    Traceable --> Ready
    Classified --> Ready
    Complete --> Ready
    Synchronized --> Ready
```

---

<details>
<summary><strong>Canonical Detail</strong></summary>

This page is an index. The full authoritative changelog entries, including task references, approval classes, migration guidance, affected consumers, and detailed summaries, remain in [`changelog/CHANGELOG.md`](https://github.com/flynn33/forsetti-agentic-edition/blob/main/changelog/CHANGELOG.md).

</details>

---

**Navigation**: [Home](Home) | [Overview](Overview) | [Workflow](Workflow) | [Compliance](Compliance) | [Agent Roles](Agent-Roles) | [Documentation](Documentation) | [Releases](Releases) | [Glossary](Glossary)
