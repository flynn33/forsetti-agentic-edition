# Forsetti Agentic Edition

**Governance Framework for AI Coding Agents and Agentic Engineering Teams**

---

## Purpose

Forsetti Agentic Edition is a governance and orchestration framework for repositories operated by AI coding agents, mixed human/AI teams, and automated software delivery systems.

It is not a runtime SDK or application framework. It is a **governance layer** that enforces disciplined delivery through:

- Constitutional governance
- Role-based authority boundaries
- Contract-driven execution
- Compliance validation with required evidence
- Release traceability
- Documentation integrity and synchronization

## Core Problem

AI-led development, without governance, produces predictable failures:

- **Uncontrolled scope expansion** — agents change more than requested
- **Undocumented changes** — modifications without documentation updates
- **Architectural drift** — structural integrity erodes across changes
- **False completion claims** — "done" without validation
- **Weak validation discipline** — tests and guardrails skipped or ignored
- **Stale documentation** — READMEs and wikis diverge from reality
- **Poor release traceability** — changes merged without version classification or changelog

Forsetti Agentic Edition exists to prevent these failures through explicit governance, not implicit trust.

---

## What It Governs

- Agent roles and authority boundaries
- Task contracts and scope binding
- Repository change control and approval workflows
- Compliance evidence and validation requirements
- Versioning discipline and release integrity
- Changelog requirements and release traceability
- Documentation synchronization and drift prevention
- Portable core boundaries
- Optional host adapters
- Platform overlays

## What It Does Not Govern

- Application runtime behavior
- UI design systems
- Language-specific implementation details
- Business-domain logic
- Deployment platform internals

These concerns belong to downstream repositories and their own governance models.

---

## Portable Architecture

Forsetti Agentic Edition is organized around a portable governance core, optional adapters, and platform overlays.

| Layer | Path | Purpose |
|---|---|---|
| Portable core | `core/` | Host-neutral governance doctrine, role boundaries, contract concepts, evidence requirements, canonical policy registries, and future validation interfaces. |
| Adapters | `adapters/` | Optional host integrations that translate local or hosted platform context into portable validation inputs. |
| Overlays | `overlays/` | Platform-specific execution guidance that preserves core governance meaning while documenting local expectations. |

The portable core must not depend on adapters, overlays, hosted workflow runners, IDEs, local MCP servers, container runtimes, or provider-specific tooling. Those tools may support evidence collection in a governed task, but they are not core product dependencies.

GitHub Actions support belongs in `adapters/github-actions/` as an optional adapter surface. It does not define canonical compliance rules.

---

## Document Hierarchy

Authority flows downward. Higher-ranked documents override lower-ranked documents in case of conflict.

| Rank | Document(s) | Authority |
|------|-------------|-----------|
| 1 | `FORSETTI_CONSTITUTION.md` | Highest. Foundational principles and governance doctrine. |
| 2 | Policy documents | Binding governance policies. |
| 3 | `standards/*.md` | Operational standards for naming, versioning, changelog, documentation, review. |
| 4 | `contracts/*.md` | Task contract templates that bind agent scope. |
| 5 | `core/policies/*.json`, `policies/*.json` | Machine-readable policy manifests. `core/policies/` contains canonical portable registries where present; matching root `policies/` files are compatibility mirrors unless a higher-authority policy says otherwise. |
| 6 | `agents/*.md` | Role-specific agent instructions. |
| 7 | `wiki/*.md` | Derived summary content. Not canonical. |

Portable documents under `core/`, `adapters/`, and `overlays/` are subordinate documentation surfaces introduced for portability, except for canonical portable policy registries explicitly designated under `core/policies/`. They do not amend the constitutional authority hierarchy.

### Local Validation

The portable core includes a local validator at `core/validator/forsetti_validate.ps1`. Repository scripts under `scripts/` delegate to that validator so local checks and future optional adapters use the same repository-local validation entry point.

The validator supports repository structure, JSON, policy mirror, documentation sync, schema, script wrapper, and task contract checks. Contract mode enforces changed files against the governing task contract scope, checks protected-path approval class requirements from `core/policies/repo-boundaries.json`, checks role-limited path rules, verifies required outputs and evidence artifacts, checks same-change documentation sync for changed canonical sources, and validates changelog entries for required fields, migration guidance, affected consumers, Unreleased placement, and version consistency:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\core\validator\forsetti_validate.ps1 `
  -RepoRoot . `
  -Mode contract `
  -ContractPath .\contracts\TASK-CONTRACT.md `
  -ChangedFilesPath .\changed-files.txt `
  -Strict
```

Validator result findings include the compliance rule identifier and, when a machine-readable policy gate supplies one, the policy rule identifier, condition identifier, and gate identifier used to reach the finding.

### Policy Documents (Rank 2)

- `COMPLIANCE_POLICY.md` — Canonical compliance registry, evidence requirements, and compliance outcomes
- `CHANGE_CONTROL_POLICY.md` — Change classification, approval workflows, scope control
- `RELEASE_POLICY.md` — Versioning discipline, changelog requirements, release readiness
- `DOCUMENTATION_POLICY.md` — Canonical sources, wiki role, synchronization rules

---

## Role Model

Forsetti Agentic Edition defines five governed roles. Each role has explicit authority and explicit boundaries. No role may exceed its authority. Role separation ensures independent verification and prevents conflicts of interest.

### Architect

Plans tasks, creates contracts, classifies changes, identifies risks, and defines scope. The Architect determines what work should be done and how it should be bounded. The Architect does not execute implementation work.

### Builder

Executes work within contract scope. Updates documentation as required by the documentation policy. Reports blockers and scope questions to the Architect. The Builder does not approve its own work, classify releases, or modify governance documents without governance-class approval.

### Validator

Reviews scope compliance, truthfulness of completion claims, documentation accuracy, and release classification correctness. The Validator provides independent verification. The Validator does not modify production artifacts or execute implementation work during validation.

### Release Manager

Confirms version classification correctness, changelog integrity, and release readiness. The Release Manager gates releases on evidence — correct semantic version, complete changelog, passing validation. The Release Manager does not modify implementation artifacts.

### Documentation Manager

Reviews README integrity, wiki synchronization, glossary consistency, and documentation drift. The Documentation Manager enforces the documentation policy and verifies that derived surfaces remain aligned with canonical sources. The Documentation Manager has authority to block PRs for documentation violations.

---

## Default Posture

This framework operates with a **strict default posture**.

- All governance rules are enforced unless an explicit policy exception exists.
- Convenience does not override compliance.
- Shortcuts that weaken traceability, documentation integrity, or validation discipline are prohibited.
- "We'll fix it later" is not an acceptable justification for skipping required governance steps.
- Agents and human contributors are held to the same governance standard.

---

## Repository Structure

```
├── AGENTS.md
├── CHANGE_CONTROL_POLICY.md
├── CODE_OF_DELIVERY.md
├── COMPLIANCE_POLICY.md
├── CONTRIBUTING.md
├── DOCUMENTATION_POLICY.md
├── FORSETTI_CONSTITUTION.md
├── LICENSE.md
├── README.md
├── RELEASE_POLICY.md
├── VERSION
├── VISION.md
├── adapters/
  ├── github-actions/
    ├── README.md
├── agents/
  ├── architect.md
  ├── builder.md
  ├── docs-manager.md
  ├── release-manager.md
  ├── validator.md
├── changelog/
  ├── CHANGELOG.md
  ├── release-notes-template.md
├── contracts/
  ├── bugfix-contract-template.md
  ├── governance-change-template.md
  ├── release-contract-template.md
  ├── task-contract-template.md
├── core/
  ├── AGENTS.md
  ├── FORSETTI_AGENTIC_CONSTITUTION.md
  ├── README.md
  ├── contracts/
    ├── task-contract-template.json
  ├── policies/
    ├── changelog-rules.json
    ├── compliance-rules.json
    ├── docs-sync-rules.json
    ├── repo-boundaries.json
    ├── versioning-rules.json
  ├── schemas/
    ├── task-contract.schema.json
    ├── validator-result.schema.json
  ├── validator/
    ├── contract_rules.ps1
    ├── README.md
    ├── forsetti_validate.ps1
├── overlays/
  ├── forsetti-apple/
    ├── README.md
  ├── forsetti-windows/
    ├── README.md
  ├── generic/
    ├── README.md
├── policies/
  ├── agent-roles.json
  ├── changelog-rules.json
  ├── compliance-rules.json
  ├── docs-sync-rules.json
  ├── labels.json
  ├── repo-boundaries.json
  ├── versioning-rules.json
├── schemas/
  ├── compliance-report.schema.json
  ├── release-entry.schema.json
  ├── task-contract.schema.json
├── scripts/
  ├── validate-repo.ps1
  ├── validate-repo.sh
├── standards/
  ├── changelog-standard.md
  ├── documentation-standard.md
  ├── naming-standard.md
  ├── review-standard.md
  ├── versioning-standard.md
├── wiki/
  ├── Agent-Roles.md
  ├── Compliance.md
  ├── Constitution.md
  ├── Glossary.md
  ├── Home.md
  ├── Overview.md
  ├── Releases.md
  ├── Workflow.md
```

---

## Quick Start for Agents

### Step 1: Understand Governance

Read `FORSETTI_CONSTITUTION.md`. This is the highest-authority document. It establishes the foundational principles that all other documents implement. Do not skip this step.

### Step 2: Understand Your Operating Rules

Read `AGENTS.md`. This document defines the role model, workflow sequence, operating constraints, and compliance requirements that apply to all agent contributors.

### Step 3: Understand the Relevant Policy

Read the policy document relevant to your current task:

- Making changes? Read `CHANGE_CONTROL_POLICY.md`
- Validating work? Read `COMPLIANCE_POLICY.md`
- Preparing a release? Read `RELEASE_POLICY.md`
- Updating documentation? Read `DOCUMENTATION_POLICY.md`

### Step 4: Operate Under Contract

Create or receive a task contract before beginning meaningful work. The contract defines your scope, authority, expected outputs, and validation requirements. Work performed without a contract is non-compliant.

### Step 5: Follow the Workflow

The required workflow is:

1. **Contract** — Define scope and authority before starting
2. **Scope** — Work within contract boundaries; do not expand unilaterally
3. **Execute** — Implement the contracted work
4. **Validate** — Run required validation and produce evidence
5. **Release** — Classify, changelog, and gate the release on evidence

Each step has requirements defined in the relevant policy document. Skipping steps is a compliance violation.

---

## Quick Start for Human Contributors

### Reviewing Agent Work

When reviewing PRs produced by AI agents, verify:

1. A task contract exists and the PR scope matches the contract
2. The documentation impact section is completed and accurate
3. Validation evidence is present (test results, lint output, guardrail checks)
4. Changelog entry exists if required by the change class
5. Wiki sync was performed or `docs:needs-sync` label was applied if canonical sources changed

### Modifying Governance

Governance documents are protected. Modifying them requires:

1. A governance-class change classification
2. Architect proposal with rationale
3. Validator review for compliance impact
4. CODEOWNERS approval (where configured)

See `CHANGE_CONTROL_POLICY.md` for the full governance change process.

---

## Governance Contact

This framework is maintained through its own governance process. Issues, proposals, and questions should be filed as GitHub issues with the appropriate labels.

---

*This document is a canonical source. Derived wiki page: `wiki/Overview.md`.*
