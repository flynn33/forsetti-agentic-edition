# Compliance

[![Version](https://img.shields.io/badge/version-v1.0.0-blue)](https://github.com/flynn33/forsetti-agentic-edition) [![License](https://img.shields.io/badge/license-see%20repo-lightgrey)](https://github.com/flynn33/forsetti-agentic-edition/blob/main/LICENSE.md)

> **Canonical source**: [`COMPLIANCE_POLICY.md`](https://github.com/flynn33/forsetti-agentic-edition/blob/main/COMPLIANCE_POLICY.md)
> **Last synced**: v1.0.0 `4cfdb2b` — 2026-03-27

---

**Governing Authority**: FORSETTI_CONSTITUTION.md
**Policy Level**: Tier 2 (Policy Document)
**Approval Class**: Governance-Class

---

## Compliance Doctrine

Compliance is determined by **evidence**, not by confidence, assertion, or intent.

A change is compliant only when:
- All required policy conditions for the change class and scope are satisfied, **AND**
- All required evidence is present and verifiable.

A claim of compliance without supporting evidence is itself a compliance violation. The burden of proof rests on the party claiming compliance, not on the party evaluating it.

---

## Compliance Model

Every compliance evaluation produces exactly one of three outcomes:

### Pass

All required conditions are met. All required evidence is present. No unresolved issues exist. The work may proceed to the next stage (merge, release, or closure).

### Request Changes

One or more conditions are partially met or evidence is incomplete, but the issues are fixable without architectural rework or scope restructuring. The work is returned to the Builder with specific, actionable feedback. Work may not proceed until the requested changes are made and re-evaluated.

### Block

A fundamental violation has been identified. Blocking violations include:
- False completion claims
- Unauthorized scope expansion
- Protected asset violations
- Hidden failures
- Truthfulness violations

Blocked work **may not proceed** until the blocking violation is resolved and the work is re-evaluated from the beginning of the compliance check. A block is not a request for changes — it is a determination that the work violated a hard governance constraint.

---

## Blocking Violations

The following violations result in an immediate **Block** determination. Each violation has a unique identifier for traceability.

### FAE-C001: No Task Contract or Governing Scope

Meaningful work was performed without a task contract or other governing scope document. Work without a contract is ungoverned and cannot be evaluated for compliance. All meaningful work requires a contract before execution.

### FAE-C002: Unauthorized Scope Expansion

Files were changed that are not authorized by the governing task contract. This includes drive-by edits, opportunistic cleanup, and any modification outside the contracted file list. If additional scope is needed, the contract must be amended before the work is performed.

### FAE-C003: Protected Governance Asset Modification Without Authority

A protected governance asset (as defined in `CHANGE_CONTROL_POLICY.md`) was modified without the required approval class. Protected assets include constitutional documents, policy documents, role definitions, schemas, and other governance infrastructure. Modifications require governance-class or sensitive approval depending on the asset.

### FAE-C004: False Completion Claim

Work was claimed as complete when required validation was not run, validation failed, required outputs were not delivered, or required documentation was not updated. "Done" means all contracted outputs are delivered and all required checks have passed. Anything less is partial completion and must be stated as such.

### FAE-C005: Silent Breaking Change

A change that alters the meaning, structure, or enforcement of existing governance rules was not classified as a breaking change. Breaking changes require explicit classification, elevated review, and migration guidance. Presenting a breaking change as non-breaking to avoid the required process is a blocking violation.

### FAE-C006: Missing Required Changelog Entry

A meaningful change (any change class except `none` and `metadata`) was delivered without a corresponding changelog entry. The changelog is a governance record. Every meaningful change must be recorded with its title, change class, version impact, summary, and affected area.

### FAE-C007: Missing Required Documentation Update

A change that affects documented behavior, policy, process, or interface was delivered without updating the corresponding documentation. Documentation drift — where the system changes but documentation does not — is a compliance failure, not a low-priority follow-up.

### FAE-C008: Hidden Known Failure

A known defect, test failure, unresolved edge case, or open risk was omitted from the deliverable summary or review materials. All known issues must be disclosed. Hiding failures to achieve a cleaner review is a truthfulness violation.

### FAE-C009: Assumptions Presented as Confirmed Facts

Unverified assumptions, estimates, or unconfirmed information was presented as validated truth. Assumptions must be labeled as assumptions. Estimates must be labeled as estimates. Only verified, evidence-backed claims may be presented as facts.

### FAE-C010: Contradiction Between Delivered Summary and Evidence

The completion summary, PR description, or status report contradicts the observable evidence (test results, file changes, validation output, review feedback). The summary must accurately reflect what was done, what was found, and what remains unresolved.

---

## Evidence Requirements

### Completion Evidence

Every completion claim must reference:
- Specific validation results (test output, lint results, build results)
- The list of files changed, demonstrating scope compliance
- Confirmation that required documentation was updated
- Confirmation that changelog was updated (if applicable)
- Disclosure of any known issues, risks, or deferred items

### Scope Evidence

Scope compliance must be demonstrable by comparing the actual file change list against the contracted scope. Every changed file must be traceable to the task contract. Files changed outside the contract are unauthorized.

### Documentation Evidence

Documentation compliance must be demonstrable by:
- Identifying which documentation artifacts were required to change based on the scope
- Confirming those artifacts were updated
- Confirming no documentation drift was introduced

### Release Evidence

Release compliance must be demonstrable by:
- Version impact classification for each included change
- Complete changelog entries for all meaningful changes
- Migration guidance for any breaking changes
- Confirmation that all compliance gates passed

---

## Compliance Categories

### 1. Scope Compliance

The work stayed within the authorized boundaries defined by the task contract. No files outside the contracted scope were modified. No unauthorized scope expansion occurred.

**Required evidence**: File change list compared against contract scope.

### 2. Documentation Compliance

All required documentation was updated to reflect the changes made. No documentation drift was introduced. README, wiki, inline documentation, and any contract-specified documentation artifacts are current.

**Required evidence**: List of documentation artifacts updated, confirmation of no drift.

### 3. Release Compliance

Version impact was correctly classified. Changelog entries are complete and accurate. Breaking changes (if any) are explicitly classified and include migration guidance. Release readiness conditions are satisfied.

**Required evidence**: Version impact classification, changelog entries, migration notes (if applicable).

### 4. Truthfulness Compliance

All claims in the deliverable summary, PR description, review materials, and status reports are accurate and supported by evidence. Known issues are disclosed. Assumptions are labeled. Partial completion is stated as partial.

**Required evidence**: Summary compared against actual validation results, file changes, and test output.

### 5. Governance Compliance

Protected governance assets were handled with the required authority level. Role boundaries were respected. Governance changes (if any) followed the governance-class approval process. No governance content was modified as a side-effect of non-governance work.

**Required evidence**: Approval class verification for any governance-touching changes, role authority confirmation.

---

## Truthfulness Standard

Truthfulness is a foundational principle (Principle 3 of the Forsetti Constitution). This section defines the operational standard for truthfulness in compliance evaluation.

- **"Done"** means all required outputs are delivered, all required validations have passed, and all required documentation is updated. If any of these are incomplete, the work is not done.

- **"Tested"** means tests were actually executed and results are available for review. If tests were not run, the work is not tested.

- **"Reviewed"** means a qualified reviewer evaluated the work against applicable compliance criteria. Self-review does not satisfy review requirements unless the policy explicitly permits it.

- **"No issues"** means no issues were found. It does not mean issues were not looked for. If evaluation was not performed, the correct statement is "not evaluated," not "no issues."

- **Partial completion** must be stated as partial completion. Delivering 3 of 5 contracted outputs is partial completion, not completion. The summary must identify what was delivered, what was not, and why.

- **Assumptions** must be identified as assumptions. If a decision was made based on an assumption rather than verified evidence, the assumption must be disclosed.

---

## Role Responsibilities

### Architect

- Ensures task contracts define clear, measurable compliance criteria.
- Defines acceptance criteria that map to specific compliance categories.
- Identifies which compliance categories are required for each task.
- Reviews sensitive changes for architectural compliance.

### Builder

- Produces evidence of scope compliance during execution (file change tracking, scope verification).
- Updates required documentation as part of delivery, not as a follow-up.
- Creates changelog entries for meaningful changes.
- Reports completion status accurately, including any known issues or partial completion.
- Does not claim completion without required evidence.

### Validator

- Evaluates compliance across all applicable categories.
- Renders one of three outcomes: pass, request changes, or block.
- Identifies specific violations by code (FAE-C001 through FAE-C010).
- Verifies that evidence supports the claims made in the deliverable summary.
- Does not pass work that lacks required evidence, regardless of apparent quality.

### Release Manager

- Confirms version impact classification is accurate.
- Verifies changelog entries are complete and correctly classified.
- Confirms breaking changes have migration guidance.
- Verifies release readiness conditions are satisfied.
- Does not authorize release with unresolved blocking violations.

### Documentation Manager

- Confirms required documentation was updated.
- Identifies documentation drift introduced by the change.
- Verifies README integrity and wiki synchronization.
- Confirms documentation artifacts match the current state of the governed content.
- Does not approve documentation compliance when drift exists.

---

*Compliance is not a gate to pass through — it is a standard to meet. Evidence is the only currency accepted.*

---

<sub>

**Navigation**: [Home](Home) | [Constitution](Constitution) | [Agent Roles](Agent-Roles) | [Workflow](Workflow) | [Compliance](Compliance) | [Releases](Releases) | [Changelog](Changelog) | [Glossary](Glossary)

</sub>
