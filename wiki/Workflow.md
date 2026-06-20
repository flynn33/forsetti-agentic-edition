# Workflow

[![Flow](https://img.shields.io/badge/flow-contract%20before%20action-2563eb)](Workflow)
[![Evidence](https://img.shields.io/badge/evidence-before%20completion-0f766e)](Compliance)
[![Commands](https://img.shields.io/badge/native%20commands-Apple%205%20%7C%20Windows%202-b91c1c)](Overview)

> **Canonical sources**: [`AGENTS.md`](https://github.com/flynn33/forsetti-agentic-edition/blob/main/AGENTS.md), [`CHANGE_CONTROL_POLICY.md`](https://github.com/flynn33/forsetti-agentic-edition/blob/main/CHANGE_CONTROL_POLICY.md), [`DOCUMENTATION_POLICY.md`](https://github.com/flynn33/forsetti-agentic-edition/blob/main/DOCUMENTATION_POLICY.md)

---

## Delivery Pipeline

```mermaid
%%{init: {"theme":"base","themeVariables":{"primaryColor":"#1e293b","primaryTextColor":"#ffffff","primaryBorderColor":"#93c5fd","lineColor":"#334155","secondaryColor":"#eef2ff","tertiaryColor":"#f8fafc"}}}%%
sequenceDiagram
    participant Owner as Human Owner
    participant Architect
    participant Builder
    participant Validator
    participant Release as Release Manager
    participant Docs as Documentation Manager

    Owner->>Architect: request governed work
    Architect->>Architect: classify change and approval class
    Architect->>Architect: select edition profile and project context
    Architect->>Builder: issue bounded task contract
    Builder->>Builder: implement inside scope
    Builder->>Builder: update docs, changelog, evidence
    Builder->>Validator: submit artifacts and validation proof
    Validator->>Validator: inspect scope, rules, manifests, evidence
    Validator-->>Builder: request changes or block when needed
    Validator->>Release: pass release-impact evidence
    Release->>Docs: confirm changelog and documentation state
    Docs-->>Owner: aligned delivery surface
```

---

## Governance State Machine

```mermaid
%%{init: {"theme":"base","themeVariables":{"primaryColor":"#0f172a","primaryTextColor":"#ffffff","primaryBorderColor":"#38bdf8","lineColor":"#2563eb","secondaryColor":"#f1f5f9","tertiaryColor":"#ecfeff"}}}%%
stateDiagram-v2
    [*] --> Requested
    Requested --> ContextSelected: edition + platform + version known
    ContextSelected --> Contracted: scope + outputs + evidence defined
    Contracted --> Executing: Builder starts
    Executing --> EvidenceReady: docs + changelog + validation proof
    EvidenceReady --> Validating
    Validating --> Passed: no blocking findings
    Validating --> RequestChanges: remediable gap
    Validating --> Blocked: invariant or authority failure
    RequestChanges --> Executing
    Blocked --> Contracted: repair or re-scope
    Passed --> ReleaseReview
    ReleaseReview --> DocumentationReview
    DocumentationReview --> Complete
    Complete --> [*]
```

---

## Native Product Lifecycle

```mermaid
%%{init: {"theme":"base","themeVariables":{"primaryColor":"#111827","primaryTextColor":"#ffffff","primaryBorderColor":"#34d399","lineColor":"#047857","secondaryColor":"#ecfdf5","tertiaryColor":"#f8fafc"}}}%%
flowchart LR
    Start["operator invokes native CLI"] --> Verify["bundle verify"]
    Verify --> Integrity{"bundle integrity"}
    Integrity -->|fail| Stop["stop with block result"]
    Integrity -->|pass| Command{"command family"}

    Command --> Version["version<br/>Apple + Windows"]
    Command --> Init["init<br/>Apple"]
    Command --> Doctor["doctor<br/>Apple"]
    Command --> Discover["discover<br/>Apple"]

    Init --> Layout["write .forsetti layout<br/>project/modules/profile/policy/product locks"]
    Doctor --> Health["verify installation, locks, tools, task state"]
    Discover --> Inventory["discover targets and module manifests"]
    Inventory --> Reconcile{"matches approved modules.json?"}
    Reconcile -->|yes| Pass["pass"]
    Reconcile -->|no| Review["request reconciliation"]
```

---

## Command Flow Details

| Workflow | Inputs | Validation Behavior | Outputs |
|---|---|---|---|
| `version` | optional `--format json` | emits structured product version result | product `1.0.0` |
| `bundle verify` | `--bundle-root` | checks manifest presence, schema, safe paths, duplicates, required files, hashes, optional product lock | pass or integrity failure |
| Apple `init` | repository root, bundle root, optional edition/platform/framework/deployment, `--dry-run` | verifies bundle, requires git repo, resolves profile, installs governed layout atomically | `.forsetti` files and instruction section |
| Apple `doctor` | repository root, bundle root | verifies bundle, install files, instruction section, profile/policy/product locks, native tools, task state | pass/request/block findings |
| Apple `discover` | repository root, bundle root, optional output | verifies bundle, inspects SwiftPM, Xcode, CMake, MSBuild markers, manifests, module edges, source roots | proposed modules inventory and reconciliation findings |

---

## Local Validator Mode Map

| Mode | Scope | Required Inputs |
|---|---|---|
| `repo` | FFAE repository structure and files | repository root |
| `contract` | task contract scope and evidence gates | contract path, changed-file evidence |
| `project-context` | Forsetti target context completeness | project context path |
| `edition-profile` | selected profile shape and fit | edition profile path |
| `manifest` | module manifest conformance | manifest path and selected profile |
| `dependencies` | dependency direction constraints | changed files, profile, target repo evidence |
| `capabilities` | declared capability before use | manifest and changed files |
| `module-isolation` | direct module boundaries | changed files and module inventory evidence |
| `evidence` | completion proof mapped to selected profile | evidence paths and selected profile |
| `all` | repository-local aggregate checks | repository root |

---

## Pull Request Gate Flow

```mermaid
%%{init: {"theme":"base","themeVariables":{"primaryColor":"#1f2937","primaryTextColor":"#ffffff","primaryBorderColor":"#fbbf24","lineColor":"#92400e","secondaryColor":"#fffbeb","tertiaryColor":"#f8fafc"}}}%%
flowchart TB
    PR["Pull request"] --> Template["PR Policy Check<br/>required sections"]
    PR --> Changelog["Changelog Validation"]
    PR --> Version["Version Guard"]
    PR --> Protected["Protected Path Check"]
    PR --> Accountability["Accountability Guard"]

    Template --> Decision{"all gates pass?"}
    Changelog --> Decision
    Version --> Decision
    Protected --> Decision
    Accountability --> Decision

    Decision -->|yes| Review["human review"]
    Decision -->|no| Repair["repair metadata, docs, policy, or evidence"]
```

---

## Failure Handling Rules

| Symptom | Correct Response |
|---|---|
| Missing task contract | Stop before implementation and create or request the contract. |
| Missing Forsetti project context | Stop Builder execution until edition, platform, version, manifest, capabilities, and API boundary status are known. |
| Bundle hash mismatch | Treat as integrity failure; do not continue native product operations. |
| Unsupported command | Return invalid usage with a blocking finding. |
| Missing validation tool | Report the exact unavailable tool and do not call the check passing. |
| Docs or changelog drift | Update derived surfaces in the same change or record an approved deferral. |
| Direct module edge discovered | Request reconciliation and route interaction through framework public contracts. |

---

**Navigation**: [Home](Home) | [Overview](Overview) | [Compliance](Compliance) | [Agent Roles](Agent-Roles) | [Documentation](Documentation) | [Releases](Releases) | [Changelog](Changelog) | [Constitution](Constitution) | [Glossary](Glossary)
