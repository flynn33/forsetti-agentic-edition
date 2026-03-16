# Contributing to Forsetti Agentic Edition

**This repository is governance-first.** All contributions must conform to the governance rules defined in this repository. Convenience does not override compliance. Speed does not override correctness. Good intentions do not override process.

## Before You Begin

Read the following documents before contributing meaningful changes. These are not optional reading.

1. `README.md` — Repository identity, purpose, and structure
2. `FORSETTI_CONSTITUTION.md` — Foundational principles and authority hierarchy
3. `AGENTS.md` — Operating rules, role model, and global prohibitions
4. `COMPLIANCE_POLICY.md` — What compliance means and what blocks a contribution
5. `CHANGE_CONTROL_POLICY.md` — Change classes, approval classes, and scope rules

Contributions that violate rules defined in these documents will be rejected regardless of technical quality.

## What Is a Meaningful Change

A change is meaningful if it alters any of the following:
- Governance rules or policy content
- Role definitions or authority boundaries
- Contract templates or schemas
- Standards documents
- Wiki content
- Changelog entries
- GitHub workflows or automation
- PR templates or issue templates
- CODEOWNERS
- Labels or label definitions

Meaningful changes require task contracts.

Changes that are purely metadata (whitespace, formatting that does not affect meaning) may be classified as `metadata` and are exempt from full contract requirements. If a change classified as `metadata` actually affects meaning, it must be reclassified and a task contract must be created.

## Task Contract Requirement

Every meaningful change must have a governing task contract created from the templates in `contracts/`. The contract defines:
- Scope of the work
- Authority (acting role and approval class)
- Expected outputs
- Validation requirements
- Definition of done

Work without a governing contract is a blocking violation (`FAE-C001`). This rule has no exceptions for urgency, simplicity, or good faith.

## Forbidden Behaviors

The following are prohibited and will result in rejection or blocking:

### Drive-By Edits
Modifying files unrelated to the task contract scope. Even beneficial changes outside scope are violations. If you notice something that needs fixing outside your scope, file a separate issue.

### Silent Breaking Changes
Making breaking changes without explicit classification as `major` or `breaking-change`. Breaking changes require migration notes and elevated approval.

### Hidden Failures
Knowing about an issue and not disclosing it in the completion summary. Honest disclosure of known limitations is required. Concealment is a blocking violation.

### Casual Protected-Asset Edits
Modifying governance documents (constitution, compliance rules, policies) without governance-class authority. Protected assets require governance-class approval regardless of the size of the change.

### False Completion Claims
Claiming work is done when validation was not run, failed, or was skipped. "Done" means all required outputs delivered and validated. Partial completion must be stated as partial.

### Scope Expansion Without Amendment
Adding work beyond the contract scope without amending the contract first. The contract defines the boundaries. Expanding beyond them requires an amendment, not an apology after the fact.

### Bundling Governance With Non-Governance Work
Governance changes must be standalone. Bundling them with feature work, refactoring, or other non-governance changes obscures the governance change and complicates review.

## Pull Request Expectations

Every PR must include the following information. Missing fields will result in the PR being returned for correction before review begins.

- **Task reference**: Link to the governing task contract or issue
- **Acting role**: The role executing the work (must be a valid role from the role model)
- **Change class**: Classification of the change (from CHANGE_CONTROL_POLICY)
- **Approval class**: Required approval level (standard, sensitive, or governance)
- **Release impact**: Version impact classification (from the Versioning Standard)
- **Documentation status**: What documentation was updated, or a specific justification for why no documentation update was required
- **Changelog status**: Whether a changelog entry was added, or a specific justification for why one is not required
- **Validation statement**: What validation was performed and the results (pass, fail with details, or blocked with reason)
- **Known risks**: Any known issues, limitations, or risks — or an explicit statement of "none"

## Acceptance Standard

Acceptable contributions are governance-conforming contributions. Technical quality is necessary but not sufficient.

A contribution that is technically correct but violates governance rules will not be accepted until governance requirements are met. This includes:
- Missing task contract
- Undocumented changes
- Hidden scope expansion
- Missing changelog entry
- Incorrect version classification
- False or incomplete completion summary

Fix the governance issues first. The technical work will wait.
