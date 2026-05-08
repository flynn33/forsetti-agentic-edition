# CHANGE CONTROL POLICY

**Governing Authority**: FORSETTI_CONSTITUTION.md
**Policy Level**: Tier 2 (Policy Document)
**Approval Class**: Governance-Class

---

## Meaningful Change Definition

A change is **meaningful** if it alters any of the following:

- Governance rules or policy content
- Role definitions or authority boundaries
- Contract templates or task contract structure
- Standards documents
- Schema definitions
- Wiki content
- Changelog entries
- GitHub workflows
- PR or issue templates
- CODEOWNERS
- Labels or label definitions
- Machine-readable policy manifests
- Agent instructions

A change is **metadata-only** if it affects only whitespace, formatting, punctuation, or cosmetic presentation **without altering the meaning, structure, or enforcement** of any governed content. Metadata-only changes may be classified as `metadata` and are exempt from full contract requirements, but must still be reviewed.

When in doubt, classify the change as meaningful. Underclassification is a greater risk than overclassification.

---

## Change Classes

Every change must be classified into exactly one of the following classes before review:

### feature

A new governance capability, policy, standard, template, workflow, schema, or other governed artifact that did not previously exist. Features add to the governance framework without altering existing rules.

### bugfix

Correction of an error in existing governance content. This includes wrong cross-references, broken workflow logic, invalid schema definitions, incorrect policy references, and factual errors. A bugfix does not change the intent of the governance rule — it corrects a defect in its expression.

### refactor

Restructuring governance content without changing its meaning or enforcement. This includes reorganizing sections, splitting documents, consolidating duplicates, or improving clarity — provided the policy meaning remains identical before and after the change.

### docs

Documentation-only change that does not alter policy. This includes README updates, wiki additions, inline comment improvements, and explanatory content. A `docs` change must not modify any policy rule, standard, schema, or enforcement mechanism.

### governance

Change to constitutional, policy, or compliance content. This is the class for changes that modify the rules themselves — not the documentation about the rules. Governance changes require governance-class approval.

### release

Release preparation work. This includes version bumps, release note compilation, changelog finalization, and release artifact generation. Release changes are governed by the Release Manager and require release-critical approval.

### metadata

Whitespace, formatting, punctuation, or trivial cosmetic changes that do not affect meaning, structure, or enforcement. Metadata changes are exempt from full contract requirements but must still be reviewed and must not alter governed content.

### breaking-change

Any change that alters the meaning, structure, or enforcement of existing governance rules in a way that **existing consumers must adapt to**. Breaking changes require explicit classification, elevated review, and migration guidance. See the Breaking Change Rules in `RELEASE_POLICY.md` for full requirements.

---

## Approval Classes

Every change is assigned an approval class that determines the required review authority:

### Standard

The default approval class. The Builder executes the work, and the Validator reviews it. No elevated authority is required. Applies to routine features, bugfixes, refactors, docs, and metadata changes that do not touch sensitive or protected assets.

### Sensitive

Applies to changes that touch multiple policy areas, impact downstream consumers, modify agent instructions, alter schemas, or affect GitHub workflows. Requires Architect review in addition to Validator review. Sensitive changes carry higher risk and require broader evaluation.

### Governance-Class

Applies to changes that modify constitutional, compliance, policy, or other protected governance documents. Requires Governance Steward authority. Governance-class changes must be standalone — they must not be bundled with non-governance work. This is the highest operational approval class.

### Emergency

Applies to critical fixes that must be deployed immediately to prevent governance failure, workflow breakage, or blocking conditions. Emergency changes use a reduced review process but **require full post-hoc validation** within 24 hours. Emergency classification does not waive compliance — it defers full evaluation, and the deferred evaluation is mandatory.

### Release-Critical

Applies to release preparation work. Requires Release Manager authority. Release-critical changes are scoped to version bumps, changelog finalization, release notes, and release artifacts. Release-critical changes must not include policy modifications or feature additions.

---

## Scope Control

Scope is binding. The Forsetti Constitution (Principle 2) establishes that the task contract defines the authorized boundaries of work. This section operationalizes that principle.

### Scope Is Defined by the Contract

The task contract lists the files, directories, and artifacts that may be modified. Only changes to contracted items are authorized. The contract may also define exclusions — items that must not be modified even if they are adjacent to the work.

### Drive-By Edits Are Prohibited

A drive-by edit is an unplanned change to a file that is not in the task contract scope, made because the Builder noticed something while working on contracted files. Drive-by edits are unauthorized scope expansion regardless of their merit. If the edit is needed, a separate task contract must be created.

### Opportunistic Cleanup Is Prohibited

Cleaning up code, formatting, or documentation outside the contracted scope is not permitted, even if the cleanup is obviously beneficial. Scope discipline exists to make changes reviewable, traceable, and auditable. Uncontracted cleanup defeats all three.

### Hidden Scope Expansion Is a Blocking Violation

If a review reveals files changed outside the contracted scope, the change is blocked under FAE-C002 (Scope Boundary Enforcement). This is not a request-changes condition — it is a block. The unauthorized changes must be removed, and if the expanded scope is needed, the contract must be amended.

### Scope Amendment Process

If additional scope is needed during execution:

1. The Builder identifies the additional scope requirement.
2. The Builder requests a contract amendment from the Architect.
3. The Architect evaluates the request and updates the contract scope.
4. Only after the amendment is approved may the Builder modify the newly authorized files.

Scope amendments must be documented in the task contract. Verbal or implicit scope expansion is not valid.

---

## Protected Assets

The following governance paths require elevated handling. Modifications to these assets without the specified approval class are blocking violations (FAE-C004).

| Protected Asset | Required Approval Class |
|---|---|
| `FORSETTI_CONSTITUTION.md` | Governance-Class |
| `COMPLIANCE_POLICY.md` | Governance-Class |
| `CHANGE_CONTROL_POLICY.md` | Governance-Class |
| `RELEASE_POLICY.md` | Governance-Class |
| `DOCUMENTATION_POLICY.md` | Governance-Class |
| `AGENTS.md` | Governance-Class |
| `core/policies/*.json` | Governance-Class |
| `policies/*.json` | Sensitive or Governance-Class (depending on content) |
| `schemas/*.json` | Sensitive |
| `agents/*.md` | Sensitive |
| `.github/CODEOWNERS` | Governance-Class |
| `.github/workflows/*.yml` | Sensitive |

### Policy Manifest Classification

Files in `core/policies/*.json` are canonical portable policy registries and require **Governance-Class** approval.

Files in `policies/*.json` require:
- **Governance-Class** if the manifest encodes constitutional, compliance, or policy rules.
- **Sensitive** if the manifest encodes operational configuration, label definitions, or workflow parameters.

When a root `policies/*.json` file mirrors a `core/policies/*.json` file, the root file is a compatibility mirror and must not redefine the canonical rule meaning.

When in doubt, apply the higher classification.

---

## Required Workflow

Every meaningful change must follow this workflow. Steps may not be skipped or reordered.

### 1. Task Contract Creation (Architect)

The Architect creates a task contract that defines:
- Scope (files authorized to change)
- Change class
- Acceptance criteria
- Required compliance categories
- Required documentation updates
- Required reviewers

### 2. Scope Confirmation and Approval

The scope is reviewed and approved. For sensitive or governance-class changes, the appropriate elevated authority must approve the scope before work begins.

### 3. Work Execution Within Scope (Builder)

The Builder executes the work strictly within the contracted scope. The Builder tracks file changes and produces compliance evidence as part of execution.

### 4. Documentation Update

The Builder updates all documentation artifacts required by the task contract. Documentation is part of delivery (Constitution Principle 5), not a follow-up activity.

### 5. Changelog Update

If the change is meaningful (any class except `none` and `metadata`), the Builder creates a changelog entry with: title, change class, version impact, summary, and affected area.

### 6. Validation (Validator)

The Validator evaluates the change against all applicable compliance categories. The Validator renders a pass, request-changes, or block decision based on evidence.

### 7. Release Impact Classification (Release Manager, if applicable)

If the change affects the release version, the Release Manager classifies the version impact and confirms changelog accuracy.

### 8. Documentation Sync Confirmation (Documentation Manager, if applicable)

If the change affects documented content, the Documentation Manager confirms that documentation is synchronized and no drift was introduced.

---

## Review Requirements by Change Type

| Change Class | Minimum Reviewer | Approval Class |
|---|---|---|
| feature | Validator | Standard |
| bugfix | Validator | Standard |
| refactor | Validator | Standard |
| docs | Documentation Manager | Standard |
| governance | Validator + Governance Steward | Governance-Class |
| release | Release Manager | Release-Critical |
| metadata | Any reviewer | Standard |
| breaking-change | Validator + Architect | Sensitive or Governance-Class |

### Notes on Review Requirements

- **Breaking changes** require Sensitive approval at minimum. If the breaking change modifies governance content, it requires Governance-Class approval.
- **Governance changes** always require the Governance Steward regardless of the magnitude of the change. There is no "minor governance change" exception.
- **Emergency changes** use reduced review at the time of merge but require full post-hoc validation with the standard review requirements.

---

## Rejection Conditions

A change **must be rejected** (blocked or returned for changes) if any of the following conditions are true:

1. **No task contract or governing scope exists.** The work has no contract and therefore no authorized scope. (FAE-C001)

2. **Files outside contract scope were modified.** Unauthorized files appear in the change set. (FAE-C002)

3. **Required documentation was not updated.** The change affects documented behavior but documentation was not updated. (FAE-C008)

4. **Required changelog entry is missing.** A meaningful change was delivered without a changelog entry. (FAE-C005)

5. **Release impact was not classified.** The change has version implications but no version impact classification was provided. (FAE-C009)

6. **Protected asset was modified without required authority.** A governance or sensitive asset was changed without the appropriate approval class. (FAE-C004)

7. **Completion summary contradicts evidence.** The delivered summary does not match the observable file changes, test results, or validation output. (FAE-C007)

8. **Known failures are not disclosed.** The deliverable omits known defects, test failures, or unresolved issues. (FAE-C011)

9. **Breaking change was not classified as such.** A change that alters existing governance rules for consumers was not classified as `breaking-change`. (FAE-C006)

10. **Governance change was bundled with non-governance work.** A governance modification was included in a task contract scoped to non-governance work. (FAE-C010)

Rejection is not punitive. Rejection protects the integrity of the governance framework. Every rejection must include specific, actionable feedback referencing the applicable violation code.

---

*Scope discipline is not bureaucracy — it is the mechanism that makes changes reviewable, traceable, and auditable. Without it, governance is theater.*
