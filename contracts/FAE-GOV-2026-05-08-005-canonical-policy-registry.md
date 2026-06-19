# Governance Change Contract: Canonical Policy Registry

## Task ID

**Value:** FAE-GOV-2026-05-08-005

## Title

**Value:** Canonical policy registry

## Date

**Value:** 2026-05-08

## Initiating Request

**Value:** Repository owner approved proceeding to Phase 02 of the v3 remediation plan.

## Acting Role

**Value:** builder

## Reviewer Role

**Value:** architect-reviewer, security-auditor, documentation_manager, validator, and governance_steward

## Change Class

**Value:** breaking-change

## Approval Class

**Value:** governance-class

## Governance Steward Authorization

**Value:** Flynn33 approved Phase 02 governance-class work on branch `fix/v3-canonical-policy-registry` on 2026-05-08 after explicit authorization request.

## Objective

**Value:** Normalize FAE-C001 through FAE-C012 into one canonical registry and align Markdown and JSON references to the same rule identifiers, titles, and meanings.

## Breaking Change Rationale

**Value:** This change corrects compliance rule identifiers whose Markdown meanings conflict with machine-readable JSON meanings. Consumers that referenced old Markdown meanings for FAE-C004, FAE-C007, or FAE-C010 must update those references to the canonical registry meanings.

## Business Reason

**Value:** Before Phase 02, `COMPLIANCE_POLICY.md` and `wiki/Compliance.md` defined compliance IDs with meanings that contradicted `policies/compliance-rules.json`. Phase 02 requires a portable core registry under `core/policies/` and elimination of the compliance-rule ID drift before local validator and contract enforcement phases can rely on rule IDs.

## In Scope

- `contracts/FAE-GOV-2026-05-08-005-canonical-policy-registry.md`
- `core/README.md`
- `core/policies/compliance-rules.json`
- `core/policies/repo-boundaries.json`
- `core/policies/docs-sync-rules.json`
- `core/policies/versioning-rules.json`
- `core/policies/changelog-rules.json`
- `policies/compliance-rules.json`
- `policies/repo-boundaries.json`
- `policies/docs-sync-rules.json`
- `COMPLIANCE_POLICY.md`
- `CHANGE_CONTROL_POLICY.md`
- `RELEASE_POLICY.md`
- `AGENTS.md`
- `README.md`
- `changelog/CHANGELOG.md`
- `wiki/Compliance.md`
- `wiki/Workflow.md`
- `wiki/Releases.md`
- `wiki/Agent-Roles.md`
- `wiki/Overview.md`
- `wiki/Home.md`
- `wiki/Changelog.md`
- `.forsetti/remediation-v3/phase-02-report.md`
- `.forsetti/remediation-v3/phase-02-report.json`

## Out of Scope

- `FORSETTI_CONSTITUTION.md`
- `DOCUMENTATION_POLICY.md`
- GitHub workflow conversion
- Pull request template changes
- Contributor attribution guard behavior
- Local validator implementation
- Contract schema enforcement implementation
- Phase 03 through Phase 09 outputs

## Required Outputs

- Canonical compliance registry with exactly FAE-C001 through FAE-C012.
- Root compliance rule mirror aligned with the core compliance registry.
- Core copies of repo-boundaries, docs-sync, versioning, and changelog policy manifests.
- Root docs sync manifest aligned with the core compliance registry path for compliance-rule documentation sync.
- Markdown compliance policy aligned to canonical rule IDs and meanings.
- Derived wiki and documentation surfaces updated where canonical sources changed.
- Changelog entry for Phase 02.
- Breaking-change migration guidance for changed compliance rule identifiers.
- Phase 02 evidence report in Markdown and JSON.

## Documentation Impact

- [x] README update required
- [x] Wiki update required
- [ ] Glossary update required
- [ ] No documentation impact

## Release Impact

**Value:** major

## Validation Requirements

- Parse all changed JSON files with `py -m json.tool`.
- Parse all changed JSON files with PowerShell `ConvertFrom-Json`.
- Verify `core/policies/compliance-rules.json` and `policies/compliance-rules.json` are byte-for-byte identical.
- Verify `core/policies/docs-sync-rules.json` and `policies/docs-sync-rules.json` are byte-for-byte identical after compliance canonical path alignment.
- Verify canonical compliance IDs are exactly FAE-C001 through FAE-C012 with no duplicates.
- Verify `COMPLIANCE_POLICY.md`, `AGENTS.md`, `CHANGE_CONTROL_POLICY.md`, `RELEASE_POLICY.md`, and derived wiki pages do not assign old meanings to FAE-C004, FAE-C007, or FAE-C010.
- Verify FAE-C011 and FAE-C012 are documented.
- Run Windows PowerShell repository validation.
- Run PowerShell 7 repository validation.
- Run Visual Studio Developer Command repository validation.
- Run targeted source-line scan over changed files.
- Verify staged files are within this contract scope.
- Obtain architect-reviewer, security-auditor, Documentation Manager, Validator, and Governance Steward evidence.

## Risks and Constraints

- This task modifies protected governance assets and requires governance-class authorization.
- Phase 02 must not alter GitHub workflow behavior or contributor guard behavior reserved for later phases.
- Phase 02 must not introduce product dependency on MCP servers, hosted providers, sub-agents, GitHub Actions, or provider-specific tooling.
- Root and core compliance registries must not diverge.

## Escalation Triggers

- A required FAE-C001 through FAE-C012 rule meaning cannot be resolved from the v3 remediation package and current repository policy.
- Required reviewer findings cannot be reconciled within the authorized scope.
- Validation fails and cannot be repaired within the contract scope.

## Definition of Done

- [x] Canonical compliance registry exists under `core/policies/`.
- [x] Root `policies/compliance-rules.json` mirrors the core compliance registry.
- [x] Required core policy manifests exist and parse.
- [x] Markdown and wiki surfaces reference the same FAE-C001 through FAE-C012 meanings.
- [x] Changelog and documentation sync obligations are satisfied.
- [x] JSON, repository, source-line, and scope validations pass.
- [x] Required reviewer outcomes are recorded.
- [x] No unresolved blocking issues remain.

## Completion Summary Requirements

- Files changed
- Evidence of validation
- Known issues
- Documentation status
- Release impact
- Scope compliance
