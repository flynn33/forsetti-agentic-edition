# Constitution

[![Authority](https://img.shields.io/badge/authority-supreme%20governance-111827)](Constitution) [![Version](https://img.shields.io/badge/version-v1.0.0-blue)](https://github.com/flynn33/forsetti-agentic-edition) [![Doctrine](https://img.shields.io/badge/doctrine-contract%20scope%20evidence-0f766e)](Compliance)

> **Canonical source**: [`FORSETTI_CONSTITUTION.md`](https://github.com/flynn33/forsetti-agentic-edition/blob/main/FORSETTI_CONSTITUTION.md)
> **Purpose**: visual orientation for the highest governing authority. The canonical repository source remains binding.

---

## Authority Stack

```mermaid
%%{init: {"theme":"base","themeVariables":{"primaryColor":"#111827","primaryTextColor":"#ffffff","primaryBorderColor":"#38bdf8","lineColor":"#475569","secondaryColor":"#eff6ff","tertiaryColor":"#f8fafc"}}}%%
flowchart TB
    C["FORSETTI_CONSTITUTION.md<br/>supreme authority"] --> P["Policy documents<br/>operational rules"]
    P --> S["Standards<br/>technical and process requirements"]
    S --> T["Contract templates<br/>task structure"]
    T --> M["Machine-readable manifests<br/>enforceable data"]
    M --> R["Role instructions<br/>behavior boundaries"]
    R --> K["Task contracts<br/>scope and acceptance criteria"]
    K --> L["Issue, PR, and workflow-local instructions<br/>lowest authority"]

    L -. may narrow only .-> C
```

---

## Foundational Principles

| Principle | Enforcement Meaning | Failure Pattern |
|---|---|---|
| Contract Before Action | Meaningful work starts from an explicit task contract. | Work begins before scope, outputs, and acceptance criteria are known. |
| Scope Is Binding | Changed files and decisions stay inside authorized boundaries. | Opportunistic cleanup or hidden expansion enters the change. |
| Truthfulness Is Mandatory | Claims must map to observable evidence. | Completion, test, release, or review claims outrun proof. |
| Governance Overrides Convenience | Required review, validation, and documentation gates are not optional. | Speed is used to justify bypassing process. |
| Documentation Is Part of Delivery | Docs, changelog, and wiki alignment are delivery artifacts. | Behavior changes while public guidance drifts. |
| Compliance Must Be Measurable | Compliance is decided by evidence, not confidence. | Assertions replace validation outputs. |
| Release Integrity Is Non-Negotiable | Version impact, changelog, and migration guidance must be accurate. | Breaking or governance-impacting work is underclassified. |

---

## Protected Doctrine

```mermaid
%%{init: {"theme":"base","themeVariables":{"primaryColor":"#0f172a","primaryTextColor":"#ffffff","primaryBorderColor":"#f59e0b","lineColor":"#92400e","secondaryColor":"#fffbeb","tertiaryColor":"#f8fafc"}}}%%
flowchart LR
    Amendment["Formal amendment"] --> Protections["Constitutional protections"]
    Protections --> Principles["7 principles"]
    Protections --> Hierarchy["authority hierarchy"]
    Protections --> Roles["role doctrine"]
    Protections --> Contracts["task contract requirement"]
    Protections --> Evidence["compliance evidence requirement"]
    Informal["informal agreement"] -. invalid .-> Protections
    LowerDoc["lower authority document"] -. cannot weaken .-> Protections
```

---

## Amendment Flow

```mermaid
%%{init: {"theme":"base","themeVariables":{"primaryColor":"#1e293b","primaryTextColor":"#ffffff","primaryBorderColor":"#93c5fd","lineColor":"#334155","secondaryColor":"#eef2ff","tertiaryColor":"#f8fafc"}}}%%
sequenceDiagram
    participant Proposer
    participant Validator
    participant Steward as Governance Steward
    participant Docs as Downstream Documents

    Proposer->>Proposer: prepare standalone amendment
    Proposer->>Validator: submit rationale, impact, rollback plan
    Validator->>Validator: verify evidence and affected surfaces
    Validator->>Steward: escalate amendment package
    Steward->>Steward: approve or reject explicitly
    Steward->>Docs: apply approved amendment and aligned updates
    Docs-->>Validator: provide synchronization evidence
```

---

## Escalation Triggers

| Trigger | Required Action |
|---|---|
| Task requires authority beyond the acting role | Stop and escalate before acting. |
| Work touches protected governance assets | Require governance-class authority. |
| Existing policy does not resolve the case | Escalate for authoritative interpretation. |
| Breaking impact appears during non-breaking work | Reclassify the contract before continuing. |
| Evidence is unavailable or inconclusive | Report the gap; do not assert compliance. |
| Governance rules conflict | Escalate to the Governance Steward. |

---

<details>
<summary><strong>Constitutional Boundary</strong></summary>

The Constitution governs the framework itself. It defines the precedence order, immutable principles, role boundaries, protected doctrine, prohibited behaviors, and amendment process. It does not replace task contracts, policy manifests, release records, or downstream framework runtime rules. Those surfaces remain valid only when they conform to the Constitution.

</details>

---

**Navigation**: [Home](Home) | [Overview](Overview) | [Agent Roles](Agent-Roles) | [Workflow](Workflow) | [Compliance](Compliance) | [Releases](Releases) | [Changelog](Changelog) | [Glossary](Glossary)
