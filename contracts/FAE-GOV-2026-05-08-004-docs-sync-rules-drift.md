# Governance Change Contract: Docs Sync Rules Drift

## Task ID

**Value:** FAE-GOV-2026-05-08-004

## Title

**Value:** Docs sync rules drift repair

## Date

**Value:** 2026-05-08

## Initiating Request

**Value:** Repository owner requested fixing the known issue that `policies/docs-sync-rules.json` drift remained after Phase 01.

## Acting Role

**Value:** builder

## Reviewer Role

**Value:** validator, documentation_manager, and governance_steward

## Change Class

**Value:** governance

## Approval Class

**Value:** governance-class

## Governance Steward Authorization

**Value:** Flynn33 confirmed Governance Steward approval for `FAE-GOV-2026-05-08-004` on branch `fix/v3-docs-sync-rules-drift` on 2026-05-08 after explicit authorization request.

## Objective

**Value:** Align the machine-readable documentation sync manifest with repository canonical documentation sources and policy-required wiki-derived pages.

## Business Reason

**Value:** `policies/docs-sync-rules.json` contains stale paths such as `CONSTITUTION.md`, `docs/glossary.md`, and `docs/compliance-guide.md` that do not match this repository. Reviewer analysis also identified drift from `DOCUMENTATION_POLICY.md` Section 4.1 for `AGENTS.md` and `DOCUMENTATION_POLICY.md` wiki-derived pages. The manifest must reflect current canonical sources so documentation drift checks can be trusted.

## In Scope

- `contracts/FAE-GOV-2026-05-08-004-docs-sync-rules-drift.md`
- `policies/docs-sync-rules.json`
- `changelog/CHANGELOG.md`
- `wiki/Changelog.md`
- `wiki/Workflow.md`
- `wiki/Documentation.md`
- `wiki/_Sidebar.md`
- `.forsetti/remediation-v3/docs-sync-rules-drift-report.md`
- `.forsetti/remediation-v3/docs-sync-rules-drift-report.json`

## Out of Scope

- `DOCUMENTATION_POLICY.md`
- `COMPLIANCE_POLICY.md`
- `CHANGE_CONTROL_POLICY.md`
- `RELEASE_POLICY.md`
- `FORSETTI_CONSTITUTION.md`
- Other policy manifests under `policies/`
- Wiki content beyond the listed wiki files required by this change
- Phase 02 canonical policy registry work

## Scope Amendment 1

**Value:** Reviewer findings established that resolving the manifest drift requires the manifest to match `DOCUMENTATION_POLICY.md` Section 4.1 exactly. That requires adding `AGENTS.md` to `wiki/Workflow.md`, replacing the `DOCUMENTATION_POLICY.md` derived page with `wiki/Documentation.md`, creating the missing documentation wiki page, updating the workflow wiki page, and adding the documentation page to wiki navigation. The in-scope file list was expanded accordingly before final validation and commit.

## Required Outputs

- Corrected `policies/docs-sync-rules.json`.
- Changelog entry for the governance change.
- `wiki/Changelog.md` synced to the changelog entry.
- `wiki/Workflow.md` aligned with `AGENTS.md` and `CHANGE_CONTROL_POLICY.md` as required by `DOCUMENTATION_POLICY.md`.
- `wiki/Documentation.md` created as the derived page for `DOCUMENTATION_POLICY.md`.
- Wiki sidebar navigation updated for the documentation page.
- Drift repair evidence report in Markdown and JSON.

## Documentation Impact

- [ ] README update required
- [x] Wiki update required
- [ ] Glossary update required
- [ ] No documentation impact

## Release Impact

**Value:** governance-only

## Validation Requirements

- Parse `policies/docs-sync-rules.json` and the drift report JSON with `py -m json.tool`.
- Parse the same JSON files with PowerShell `ConvertFrom-Json`.
- Verify every manifest `canonical` path exists in the repository.
- Verify every manifest `derived` wiki path exists in the repository.
- Verify manifest pairs include every sync pair required by `DOCUMENTATION_POLICY.md` Section 4.1.
- Run Windows PowerShell repository validation.
- Run PowerShell 7 repository validation.
- Run targeted source-line scan over changed files.
- Verify staged files are within this contract scope.
- Obtain Documentation Manager and Validator review.
- Obtain Governance Steward authorization.

## Risks and Constraints

- This task modifies a protected policy manifest and requires governance-class approval.
- The change must repair stale paths without changing root documentation policy.
- The change must not bundle Phase 02 canonical policy registry work.

## Escalation Triggers

- A required canonical or derived path cannot be resolved without changing out-of-scope files.
- Documentation policy itself must change to complete the task.
- Validation fails and cannot be repaired within scope.

## Definition of Done

- [ ] `policies/docs-sync-rules.json` reflects current repository canonical and derived documentation paths, including `DOCUMENTATION_POLICY.md` Section 4.1 pairs.
- [ ] Changelog, wiki changelog, workflow wiki, documentation wiki, and wiki navigation are updated.
- [ ] JSON and repository validations pass.
- [ ] Documentation Manager and Validator reviews pass.
- [ ] Governance Steward authorization is recorded.
- [ ] No unresolved blocking issues remain.

## Completion Summary Requirements

- Files changed
- Evidence of validation
- Known issues
- Documentation status
- Release impact
- Scope compliance
