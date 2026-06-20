# Agent Roles

[![Roles](https://img.shields.io/badge/roles-Architect%20%7C%20Builder%20%7C%20Validator%20%7C%20Release%20%7C%20Docs-2563eb)](Agent-Roles)
[![Authority](https://img.shields.io/badge/authority-separated-0f766e)](Compliance)
[![Review](https://img.shields.io/badge/review-evidence%20based-b91c1c)](Workflow)

> **Canonical sources**: [`AGENTS.md`](https://github.com/flynn33/forsetti-agentic-edition/blob/main/AGENTS.md), [`agents/*.md`](https://github.com/flynn33/forsetti-agentic-edition/tree/main/agents), `policies/agent-roles.json`

---

## Role Lattice

```mermaid
%%{init: {"theme":"base","themeVariables":{"primaryColor":"#111827","primaryTextColor":"#ffffff","primaryBorderColor":"#60a5fa","lineColor":"#334155","secondaryColor":"#eff6ff","tertiaryColor":"#f8fafc"}}}%%
flowchart TB
    Steward["Governance Steward<br/>protected governance authority"] --> Architect["Architect<br/>plans and scopes"]
    Architect --> Builder["Builder<br/>executes contracted work"]
    Builder --> Validator["Validator<br/>verifies evidence"]
    Validator --> Release["Release Manager<br/>version and release integrity"]
    Validator --> Docs["Documentation Manager<br/>docs and wiki integrity"]
    Docs --> Steward
    Release --> Steward
```

---

## Authority Matrix

| Role | Owns | Must Not Do | Required Evidence |
|---|---|---|---|
| Architect | change classification, approval class, edition profile, task scope, risk boundaries | implement or validate own plan | task contract, scope statement, selected profile |
| Builder | scoped implementation, documentation updates, changelog entry, validation evidence | expand scope, approve own work, bypass sealed boundaries | changed files, command outputs, evidence bundle |
| Validator | compliance decision, scope review, findings, truthfulness check | implement production changes during validation | validator result, finding rationale, unresolved issues |
| Release Manager | version impact, changelog integrity, release readiness | waive compliance or rewrite history casually | version classification, changelog completeness, release gate result |
| Documentation Manager | README/wiki/docs alignment, glossary consistency, drift control | change canonical policy meaning through derived docs | sync evidence, derived page updates, drift decisions |
| Governance Steward | governance-class approval, protected asset authority, constitutional escalation | weaken policy informally | explicit approval record and protected-path rationale |

---

## RACI Grid

| Activity | Architect | Builder | Validator | Release Manager | Documentation Manager | Governance Steward |
|---|---:|---:|---:|---:|---:|---:|
| Classify change | R/A | C | C | C | C | C |
| Select edition profile | R/A | C | C | I | I | C |
| Execute scoped edits | I | R/A | I | I | C | I |
| Produce validation evidence | C | R | A | C | C | I |
| Decide compliance outcome | I | C | R/A | C | C | C |
| Confirm changelog entry | C | R | C | A | C | I |
| Confirm wiki/docs sync | C | R | C | C | A | I |
| Approve governance-class work | C | I | C | C | C | R/A |

R = responsible, A = accountable, C = consulted, I = informed.

---

## Handoff Swimlane

```mermaid
%%{init: {"theme":"base","themeVariables":{"primaryColor":"#1e293b","primaryTextColor":"#ffffff","primaryBorderColor":"#38bdf8","lineColor":"#475569","secondaryColor":"#f8fafc","tertiaryColor":"#ecfeff"}}}%%
sequenceDiagram
    participant Owner as Human Owner
    participant Architect
    participant Builder
    participant Validator
    participant Release as Release Manager
    participant Docs as Documentation Manager
    participant Steward as Governance Steward

    Owner->>Architect: desired outcome
    Architect->>Architect: classify and scope
    Architect->>Builder: contract + profile + constraints
    Builder->>Builder: implement inside contract
    Builder->>Validator: artifacts + evidence
    Validator-->>Builder: findings if evidence is incomplete
    Validator->>Release: validation result
    Release->>Docs: release and changelog state
    Docs-->>Release: docs sync status
    Release->>Steward: elevated approval if required
    Steward-->>Owner: governance decision when escalated
```

---

## Role Separation Controls

| Risk | Control |
|---|---|
| Builder approves own work | Validator role must independently review scope, findings, and evidence. |
| Release impact is underclassified | Release Manager checks version impact against changelog and versioning policy. |
| Documentation silently changes policy meaning | Documentation Manager keeps derived pages subordinate to canonical sources. |
| Protected paths are modified casually | Protected-path manifest and approval-class gates route the change to higher authority. |
| Completion claims outrun validation | Evidence and validation integrity rule blocks unsupported claims. |

---

## Escalation Ladder

```mermaid
%%{init: {"theme":"base","themeVariables":{"primaryColor":"#0f172a","primaryTextColor":"#ffffff","primaryBorderColor":"#a78bfa","lineColor":"#4f46e5","secondaryColor":"#eef2ff","tertiaryColor":"#f8fafc"}}}%%
flowchart LR
    Standard["standard"] --> Sensitive["sensitive"]
    Sensitive --> Governance["governance-class"]
    Governance --> ReleaseCritical["release-critical"]
    Governance --> Emergency["emergency"]

    Standard -. docs, normal fixes .-> Builder
    Sensitive -. protected-sensitive paths .-> Architect
    Governance -. policy/schema/governance .-> Steward["Governance Steward"]
    ReleaseCritical -. release gates .-> Release["Release Manager"]
```

---

## Product Role Checklist

| Before Work | During Work | Before Completion |
|---|---|---|
| contract exists | changed files remain in scope | evidence maps to selected profile |
| edition profile selected | docs/changelog impact tracked | validator or native checks are current |
| authority class known | protected paths are not touched casually | limitations are explicit |
| required outputs named | source bundle verified where used | no derived page drift remains |

---

**Navigation**: [Home](Home) | [Overview](Overview) | [Workflow](Workflow) | [Compliance](Compliance) | [Documentation](Documentation) | [Releases](Releases) | [Changelog](Changelog) | [Constitution](Constitution) | [Glossary](Glossary)
