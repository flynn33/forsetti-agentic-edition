# Workflow

[![Version](https://img.shields.io/badge/version-v1.0.0-blue)](https://github.com/flynn33/forsetti-agentic-edition) [![License](https://img.shields.io/badge/license-see%20repo-lightgrey)](https://github.com/flynn33/forsetti-agentic-edition/blob/main/LICENSE.md)

> **Canonical sources**: [`CHANGE_CONTROL_POLICY.md`](https://github.com/flynn33/forsetti-agentic-edition/blob/main/CHANGE_CONTROL_POLICY.md), [`DOCUMENTATION_POLICY.md`](https://github.com/flynn33/forsetti-agentic-edition/blob/main/DOCUMENTATION_POLICY.md)
> **Last synced**: v1.0.0 `4cfdb2b` — 2026-03-27

---

## Change Control Policy

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

If a review reveals files changed outside the contracted scope, the change is blocked under FAE-C002 (Unauthorized Scope Expansion). This is not a request-changes condition — it is a block. The unauthorized changes must be removed, and if the expanded scope is needed, the contract must be amended.

### Scope Amendment Process

If additional scope is needed during execution:

1. The Builder identifies the additional scope requirement.
2. The Builder requests a contract amendment from the Architect.
3. The Architect evaluates the request and updates the contract scope.
4. Only after the amendment is approved may the Builder modify the newly authorized files.

Scope amendments must be documented in the task contract. Verbal or implicit scope expansion is not valid.

---

## Protected Assets

The following governance paths require elevated handling. Modifications to these assets without the specified approval class are blocking violations (FAE-C003).

| Protected Asset | Required Approval Class |
|---|---|
| `FORSETTI_CONSTITUTION.md` | Governance-Class |
| `COMPLIANCE_POLICY.md` | Governance-Class |
| `CHANGE_CONTROL_POLICY.md` | Governance-Class |
| `RELEASE_POLICY.md` | Governance-Class |
| `DOCUMENTATION_POLICY.md` | Governance-Class |
| `AGENTS.md` | Governance-Class |
| `policies/*.json` | Sensitive or Governance-Class (depending on content) |
| `schemas/*.json` | Sensitive |
| `agents/*.md` | Sensitive |
| `.github/CODEOWNERS` | Governance-Class |
| `.github/workflows/*.yml` | Sensitive |

### Policy Manifest Classification

Files in `policies/*.json` require:
- **Governance-Class** if the manifest encodes constitutional, compliance, or policy rules.
- **Sensitive** if the manifest encodes operational configuration, label definitions, or workflow parameters.

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

3. **Required documentation was not updated.** The change affects documented behavior but documentation was not updated. (FAE-C007)

4. **Required changelog entry is missing.** A meaningful change was delivered without a changelog entry. (FAE-C006)

5. **Release impact was not classified.** The change has version implications but no version impact classification was provided.

6. **Protected asset was modified without required authority.** A governance or sensitive asset was changed without the appropriate approval class. (FAE-C003)

7. **Completion summary contradicts evidence.** The delivered summary does not match the observable file changes, test results, or validation output. (FAE-C010)

8. **Known failures are not disclosed.** The deliverable omits known defects, test failures, or unresolved issues. (FAE-C008)

9. **Breaking change was not classified as such.** A change that alters existing governance rules for consumers was not classified as `breaking-change`. (FAE-C005)

10. **Governance change was bundled with non-governance work.** A governance modification was included in a task contract scoped to non-governance work.

Rejection is not punitive. Rejection protects the integrity of the governance framework. Every rejection must include specific, actionable feedback referencing the applicable violation code.

---

*Scope discipline is not bureaucracy — it is the mechanism that makes changes reviewable, traceable, and auditable. Without it, governance is theater.*

---

## Documentation Policy

**Authority**: Governance policy document. Subordinate to `FORSETTI_CONSTITUTION.md`. Binding on all contributors — human and agent.

**Effective**: From first merged commit to `main`.

**Scope**: All documentation surfaces within the repository and its derived wiki.

---

## 1. Documentation Doctrine

Documentation is part of delivery. It is not a follow-up task, a nice-to-have, or a separate workstream.

A change that materially affects understanding, usage, operation, governance, or release history is **incomplete** if documentation is not updated as required by this policy. Incomplete work must not be marked as done. PRs with outstanding documentation obligations must not be approved without either fulfilling those obligations or explicitly tracking them with the required label.

Documentation is a first-class deliverable. It is subject to the same review, approval, and compliance standards as code and governance artifacts.

---

## 2. Canonical Source Rule

Repository markdown files are the **canonical documentation source**. Every governance document, policy, standard, agent instruction file, and README that resides in the repository is authoritative.

If a conflict exists between repository markdown and any other surface — wiki, external documentation site, cached version, screenshot, conversation log, or third-party reference — the **repository markdown is authoritative**. The conflicting surface is wrong until corrected.

No external surface may override, amend, or extend a canonical source. External surfaces may only summarize, link to, or derive from canonical sources.

### 2.1 Canonical Source Inventory

The following files are canonical sources:

| File | Scope |
|---|---|
| `FORSETTI_CONSTITUTION.md` | Foundational governance principles and doctrine |
| `AGENTS.md` | Agent operating rules, role model, workflow |
| `COMPLIANCE_POLICY.md` | Compliance model, evidence requirements, blocking violations |
| `CHANGE_CONTROL_POLICY.md` | Change classification, approval workflows, scope control |
| `RELEASE_POLICY.md` | Versioning discipline, changelog requirements, release readiness |
| `DOCUMENTATION_POLICY.md` | This document — documentation standards and sync rules |
| `README.md` | Repository overview, structure, quick start |
| `VISION.md` | Mission, problem statement, strategic goals |
| `CONTRIBUTING.md` | Contributor guide |
| `CODE_OF_DELIVERY.md` | Delivery doctrine |
| `agents/*.md` | Role-specific agent instructions |
| `contracts/*.md` | Task contract templates |
| `standards/*.md` | Operational standards |

Adding a new canonical source requires a governance-class PR with Architect and Validator approval.

---

## 3. Wiki Role

The wiki (`wiki/*.md`) is a **derived publishing surface**. It exists to provide navigational summaries, cross-references, and entry points for contributors who need orientation.

### 3.1 Wiki Constraints

- Wiki pages **summarize and link to** canonical sources. They do not replace them.
- Wiki content **must never be treated as canonical**. If a wiki page contradicts a canonical source, the canonical source is correct.
- Wiki pages **must not duplicate canonical content verbatim**. They provide navigational summaries, context, and cross-references.
- Wiki pages **must include a canonical source reference** — a clear link or path to the canonical document they derive from.
- Wiki pages **must not introduce governance rules, policy statements, or binding requirements** that do not exist in a canonical source.

### 3.2 Wiki Page Format

Every wiki page must begin with:

```markdown
# [Page Title]

> **Canonical source**: `[path/to/canonical/source.md]`
> **Last synced**: [date or PR reference]
```

This header establishes traceability and makes drift detection possible.

---

## 4. Synchronization Rule

When a canonical source file is modified, the corresponding wiki-derived page **must be updated in the same PR** or a `docs:needs-sync` label **must be applied** to the PR to track the outstanding synchronization.

### 4.1 Canonical-to-Wiki Sync Pairs

| Canonical Source | Wiki Derived Page(s) |
|---|---|
| `FORSETTI_CONSTITUTION.md` | `wiki/Constitution.md` |
| `AGENTS.md` | `wiki/Agent-Roles.md`, `wiki/Workflow.md` |
| `COMPLIANCE_POLICY.md` | `wiki/Compliance.md` |
| `RELEASE_POLICY.md` | `wiki/Releases.md` |
| `CHANGE_CONTROL_POLICY.md` | `wiki/Workflow.md` |
| `DOCUMENTATION_POLICY.md` | `wiki/Documentation.md` |
| `README.md` | `wiki/Overview.md` |

When a canonical source has multiple derived wiki pages, **all** derived pages must be updated or labeled for sync.

### 4.2 Sync Completion

A `docs:needs-sync` label is a tracking mechanism, not a permanent exemption. Outstanding syncs must be completed within the next two PRs merged to `main` after the label was applied, or a dedicated documentation sync PR must be opened.

If a `docs:needs-sync` label remains unresolved after three PRs have been merged to `main`, it becomes a **blocking compliance violation**. No further feature or governance PRs may be merged until the sync is resolved.

### 4.3 Sync Direction

Synchronization is **one-directional**: canonical source to wiki. Changes must never flow from wiki to canonical source. If a wiki page contains information that should be canonical, that information must first be added to the appropriate canonical source, then the wiki page must be updated to derive from it.

---

## 5. Documentation Impact Review

Every PR must declare its documentation impact. This is not optional.

### 5.1 PR Template Documentation Section

The PR template must include a documentation impact section requiring explicit confirmation of:

- [ ] **README**: Does this change require a README update? (Yes / No / Not applicable)
- [ ] **Wiki**: Do wiki pages require update? (Yes / No / Not applicable)
- [ ] **Governance documents**: Are governance documents affected? (Yes / No / Not applicable)
- [ ] **Glossary**: Does this change introduce new terms requiring glossary update? (Yes / No / Not applicable)
- [ ] **Changelog**: Has the changelog been updated? (Yes / No / Not applicable — metadata only)

Leaving the documentation impact section blank or removing it from a PR is a **blocking violation**. The PR must not be approved until the section is completed.

### 5.2 Documentation Impact Assessment Responsibility

The PR author is responsible for the initial documentation impact declaration. The Validator role is responsible for verifying the declaration is accurate. If the Validator determines the declaration is incorrect — for example, a feature PR claims no README update is needed when it clearly introduces new repository-level capabilities — the Validator must request changes.

---

## 6. Required Documentation Updates by Change Type

The following table defines minimum documentation obligations by change class. These are minimums — contributors may exceed them.

| Change Class | README | Wiki | Glossary | Changelog |
|---|---|---|---|---|
| `feature` | If scope affects repository overview | Yes, if canonical source changed | If new terms introduced | Yes |
| `bugfix` | Only if README contained the error | Only if canonical source changed | Rarely | Yes |
| `refactor` | Only if repository structure changed | Only if canonical source changed | Rarely | Yes, if meaningful |
| `docs` | If README is the target | If wiki is the target | If glossary is the target | Only if meaningful |
| `governance` | Yes, if policy overview changed | Yes | If governance terms changed | Yes |
| `release` | Only if release process changed | Only if release wiki changed | Rarely | Yes (release entry) |
| `metadata` | No | No | No | No |
| `breaking-change` | Yes | Yes | If terms changed | Yes, with migration note |

### 6.1 Interpretation Rules

- "If canonical source changed" means the canonical source file was modified in the PR. If it was modified, wiki sync is required or must be labeled.
- "If new terms introduced" means the PR introduces terminology not already defined in the glossary. Judgment call belongs to the PR author; verification belongs to the Validator.
- "Yes, with migration note" for breaking changes means the changelog entry must include explicit migration guidance — what changed, what breaks, and what consumers must do.
- `metadata` class changes (CI configuration tweaks, label updates, non-functional repository settings) are exempt from documentation updates. This exemption does not extend to changes that affect contributor workflow, governance enforcement, or approval requirements.

---

## 7. Drift Definition

Documentation drift occurs when documented state diverges from actual state. Drift undermines trust in documentation and creates governance risk.

### 7.1 Drift Conditions

Drift exists when any of the following are true:

1. **Canonical-wiki divergence**: A canonical source has been modified but its wiki-derived page has not been updated and no `docs:needs-sync` label is tracking the gap.
2. **README inaccuracy**: README describes capabilities, structures, roles, workflows, or files that no longer exist or have materially changed.
3. **Glossary inconsistency**: A glossary term definition no longer matches its usage in policy documents, agent instructions, or standards.
4. **Wiki contradiction**: A wiki page contains information that contradicts its canonical source.
5. **Stale references**: Documentation references files, directories, tools, or processes that have been removed, renamed, or replaced.
6. **Orphaned documentation**: Documentation exists for features, roles, or processes that have been removed from the repository.

### 7.2 Drift Severity

- **Drift in governance documents** (constitution, policies, compliance model): blocking violation. Must be resolved before the next governance or feature PR is merged.
- **Drift in operational documents** (README, agent instructions, standards): compliance issue. Must be resolved within three PRs merged to `main` or via a dedicated documentation PR.
- **Drift in wiki pages**: tracked issue. Must be resolved per the sync completion rule in Section 4.2.

### 7.3 Drift Reporting

Drift is a compliance issue. **Unreported drift is a blocking violation.**

Any contributor — human or agent — who detects drift must report it by:
1. Opening an issue with the `docs:drift` label, or
2. Including the drift fix in their current PR, or
3. Noting the drift in their PR's documentation impact section with a reference to the affected files.

Detecting drift and not reporting it is equivalent to introducing drift. Both are violations.

---

## 8. Rejection Conditions

A PR **must be rejected or marked for changes** if any of the following conditions are true:

1. A canonical source was modified but wiki sync was not performed and no `docs:needs-sync` label was applied.
2. README was not updated when the change materially affects the repository overview, structure, or capabilities.
3. A breaking change was made without updating all affected documentation surfaces.
4. Documentation drift was introduced and not reported.
5. The documentation impact section of the PR template was left blank, removed, or obviously incorrect.
6. A governance document was modified without following the governance change approval class.
7. New terminology was introduced without a glossary entry when the term is used in governance or policy context.
8. A wiki page was modified to contain information not derived from a canonical source.

### 8.1 Rejection Authority

The Validator role and the Documentation Manager role both have authority to reject PRs for documentation violations. Either role may independently block a PR that fails documentation review.

### 8.2 Rejection Override

Documentation rejection may only be overridden by:
- Fixing the documentation violation, or
- Demonstrating that the rejection condition does not actually apply (with specific justification), or
- An explicit governance exception approved through the governance change process defined in `CHANGE_CONTROL_POLICY.md`.

Convenience, urgency, and "we'll fix it later" are not valid override justifications.

---

## 9. Documentation Quality Standards

### 9.1 Clarity

Documentation must be written in clear, direct language. Avoid jargon unless the term is defined in the glossary. Prefer short sentences. Prefer active voice. State requirements as requirements, not suggestions.

### 9.2 Accuracy

Documentation must accurately reflect the current state of the repository. Aspirational statements must be clearly marked as aspirational. Planned features must not be documented as existing features.

### 9.3 Completeness

Documentation must cover the scope it claims to cover. A policy document that omits material rules is incomplete. An agent instruction file that omits required workflow steps is incomplete. Incomplete documentation is a compliance issue.

### 9.4 Consistency

Terminology must be used consistently across all documentation surfaces. If the glossary defines a term, all documents must use that term with the glossary's meaning. Synonyms and informal alternatives create ambiguity and are prohibited in governance documents.

---

## 10. Changelog Documentation Requirements

Changelog entries are documentation. They are subject to this policy.

### 10.1 Changelog Entry Requirements

Every changelog entry must include:
- The change class (feature, bugfix, refactor, governance, breaking-change, etc.)
- A clear, factual summary of what changed
- The PR reference
- For breaking changes: explicit migration guidance

### 10.2 Changelog Omission

Omitting a required changelog entry is a documentation violation. The Validator and Release Manager roles must verify changelog completeness before approving a PR for merge.

---

## 11. Enforcement

This policy is enforced through:
- PR template requirements (documentation impact section)
- Validator review (documentation accuracy and completeness)
- Documentation Manager review (wiki sync, drift detection, README integrity)
- CI checks where practical (link validation, sync label verification)
- Compliance audit (drift detection across canonical sources and derived surfaces)

Violations of this policy are compliance issues subject to the enforcement mechanisms defined in `COMPLIANCE_POLICY.md`.

---

## 12. Amendment

This policy may be amended through the governance change process defined in `CHANGE_CONTROL_POLICY.md`. Amendments require Architect proposal, Validator review, and Documentation Manager review at minimum.

---

*This document is a canonical source. Derived wiki page: `wiki/Documentation.md`.*

---

<sub>

**Navigation**: [Home](Home) | [Constitution](Constitution) | [Agent Roles](Agent-Roles) | [Workflow](Workflow) | [Compliance](Compliance) | [Releases](Releases) | [Changelog](Changelog) | [Glossary](Glossary)

</sub>
