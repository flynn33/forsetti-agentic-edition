# Task Contract: Remediation Evidence Normalization

## Task ID

**Value:** FAE-META-2026-05-08-003

## Title

**Value:** Remediation evidence normalization

## Date

**Value:** 2026-05-08

## Initiating Request

**Value:** Repository owner requested fixing the known issue that pre-existing v2 and Phase 00 evidence remained untracked after Phase 01.

## Acting Role

**Value:** builder

## Reviewer Role

**Value:** validator

## Change Class

**Value:** metadata

## Approval Class

**Value:** standard

## Objective

**Value:** Normalize, validate, and track prior remediation evidence files so they are no longer loose untracked workspace artifacts.

## Business Reason

**Value:** Phase 01 intentionally excluded earlier audit evidence from its payload. This cleanup preserves that evidence in version control and removes source-line wording that conflicts with repository owner instructions for newly committed artifacts.

## In Scope

- `contracts/FAE-META-2026-05-08-003-remediation-evidence-normalization.md`
- `.forsetti/remediation-v2/baseline-report.json`
- `.forsetti/remediation-v2/baseline-report.md`
- `.forsetti/remediation-v2/changed-files-baseline.txt`
- `.forsetti/remediation-v2/phase-00-completion.json`
- `.forsetti/remediation-v2/phase-00-completion.md`
- `.forsetti/remediation-v3/local-mcp-inventory-report.md`
- `.forsetti/remediation-v3/local-mcp-inventory.json`
- `.forsetti/remediation-v3/local-subagent-inventory-report.md`
- `.forsetti/remediation-v3/local-subagent-inventory.json`
- `.forsetti/remediation-v3/mcp-provider-decision-log.json`
- `.forsetti/remediation-v3/mcp-subagent-execution-policy.json`
- `.forsetti/remediation-v3/mcp-subagent-execution-policy.md`
- `.forsetti/remediation-v3/phase-00-baseline-report.md`
- `.forsetti/remediation-v3/phase-00-baseline.json`
- `.forsetti/remediation-v3/phase-00b-report.md`
- `.forsetti/remediation-v3/tool-discovery-report.md`
- `.forsetti/remediation-v3/tool-discovery.json`
- `.forsetti/remediation-v3/evidence-normalization-report.md`
- `.forsetti/remediation-v3/evidence-normalization-report.json`

## Out of Scope

- `policies/docs-sync-rules.json`
- Other policy manifests under `policies/`
- Root governance policy documents
- `COMPLIANCE_POLICY.md`
- Phase 02 canonical policy registry work
- Any deletion of prior evidence

## Required Outputs

- Prior v2 and Phase 00/00A/00B evidence files tracked as an intentional payload.
- Evidence wording normalized to avoid prohibited source/contributor source-line wording in newly tracked artifacts.
- `.forsetti/remediation-v3/evidence-normalization-report.md`
- `.forsetti/remediation-v3/evidence-normalization-report.json`

## Documentation Impact

- [ ] README update required
- [ ] Wiki update required
- [ ] Glossary update required
- [x] No documentation impact

## Release Impact

**Value:** none

## Validation Requirements

- Parse all in-scope JSON files with `py -m json.tool`.
- Parse all in-scope JSON files with PowerShell `ConvertFrom-Json`.
- Run the repository validator with Windows PowerShell.
- Run the repository validator with PowerShell 7.
- Run a targeted scan proving in-scope files contain no prohibited source or contributor source-line wording.
- Verify the staged payload exactly matches this contract scope.

## Risks and Constraints

- This task must not modify protected policy manifests.
- This task must preserve evidence rather than deleting it.
- This task must remain metadata-only and must not change framework rules.
- The docs-sync policy drift known issue must be handled in a separate governance-class task.

## Escalation Triggers

- Evidence files cannot be parsed after normalization.
- Normalization would materially alter evidence meaning rather than wording.
- A protected policy file must be changed to complete the task.

## Definition of Done

- [ ] All in-scope evidence files are tracked or intentionally staged.
- [ ] Required report files are produced.
- [ ] JSON validation passes.
- [ ] Repository validation passes.
- [ ] Source-line scan passes.
- [ ] No out-of-scope files are staged.

## Completion Summary Requirements

- Files changed
- Evidence of validation
- Known issues
- Documentation status
- Release impact
- Scope compliance
