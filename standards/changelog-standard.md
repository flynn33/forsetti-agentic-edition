# Changelog Standard

This standard defines how changelog entries are written, structured, and maintained in the Forsetti Agentic Edition. The changelog is a governance record. It exists to provide traceable, accurate, and reviewable history of all meaningful repository changes. It is not marketing copy, release notes prose, or decorative content.

## Required Fields

Every changelog entry must include the following fields:

### title

Brief descriptive title of the change. Must be specific enough to distinguish this change from other changes in the same release.

### change_class

Classification from CHANGE_CONTROL_POLICY. Valid values:
- `feature`
- `bugfix`
- `refactor`
- `docs`
- `governance`
- `release`
- `metadata`
- `breaking-change`

### version_impact

Classification from RELEASE_POLICY and the Versioning Standard. Valid values:
- `none`
- `patch`
- `minor`
- `major`
- `governance-only`

### summary

One to three sentences describing what changed and why. Must be specific and evidence-based. Must not be vague or generic.

### affected_area

Which part of the governance framework was affected. Valid values include but are not limited to:
- `policies`
- `schemas`
- `agents`
- `workflows`
- `standards`
- `contracts`
- `wiki`
- `changelog`
- `templates`

## Additional Required Fields for Breaking Changes

When a change is breaking, the following additional fields are mandatory:

### breaking_change

Must be set to `true`.

### migration_note

What consumers must do to adapt to this change. Must be specific and actionable. "See documentation" is not an acceptable migration note.

## Optional Fields

### task_reference

Link or ID of the governing task contract (e.g., `FAE-TASK-001` or a URL to the issue).

### approval_class

The approval class used for this change (e.g., `standard`, `sensitive`, `governance`).

## Writing Guidelines

### Be Specific

Summaries must describe what changed and why, not just "updated X."

- Acceptable: "Added validation for changelog entries in policy-check workflow to enforce required fields before merge."
- Unacceptable: "Updated workflow."

### Describe Corrections Accurately

If a change is a correction, state what was wrong and what the fix does.

- Acceptable: "Fixed broken cross-reference from COMPLIANCE_POLICY.md to CHANGE_CONTROL_POLICY.md. Reference pointed to a renamed file."
- Unacceptable: "Fixed link."

### Document Breaking Changes Fully

Breaking changes must explain what breaks and how to migrate.

- Acceptable: "Changed `task_reference` from optional to required in task-contract.schema.json. All existing task contracts must be updated to include a `task_reference` field."
- Unacceptable: "Updated schema."

## When Entries Are Required

Every meaningful change requires a changelog entry. The only exempt change classes are `none` and `metadata`.

If a change class is `metadata` but the change actually affects meaning, it must be reclassified to the appropriate change class and a changelog entry must be added. Misclassifying a meaningful change as `metadata` to avoid changelog requirements is a compliance violation.

## Format and Location

Entries are added to `changelog/CHANGELOG.md` in reverse chronological order (newest first). Each entry uses the required field structure defined in this standard.

## Governing Principle

The changelog must be trustworthy. An entry that obscures, minimizes, or misrepresents a change is a compliance violation. The changelog is auditable evidence of repository history. Treat it accordingly.

## Forsetti Enforcement Entries

Changes to edition profiles, Forsetti enforcement rules, manifest schemas, validator modes, task context requirements, capability rules, dependency boundaries, module-isolation rules, or public API boundary rules must be recorded as governance-impacting changes. Breaking changes must include affected consumers and migration guidance.
