# Task Contract: Policy Paths, Docs, Changelog, and Release Accuracy

## Contract Identity

**Task ID:** FAE-GOV-2026-05-10-008
**Branch:** fix/v3-policy-paths-docs-release
**Created:** 2026-05-10
**Repository:** Forsetti Agentic Edition

## Role Assignment

**Contract Authoring Role:** Architect
**Acting Role:** Builder
**Reviewer Role:** Validator
**Release Review Role:** Release Manager
**Documentation Review Role:** Documentation Manager

## Required Advisory Reviewers

- documenter
- api-designer
- devops-engineer
- security-auditor
- code-reviewer

## Change Classification

**Change Class:** breaking-change
**Approval Class:** governance-class
**Release Impact:** major

## Governance Steward Authorization

**Required:** yes
**Authority:** Flynn33, repository owner and Governance Steward
**Evidence:** Flynn33 confirmed Phase 04 was merged and directed continuation to the next phase on 2026-05-10. This phase will be completed on branch `fix/v3-policy-paths-docs-release`, pushed for pull request review, and merged only after repository-owner review.

## Objective

Correct stale policy paths, make documentation, changelog, and version policy data enforceable before merge, and prevent retroactive mutation of governance records.

## Business Reason

Policy manifests must represent the current repository structure and encode enough rule data for local validation and optional adapters to evaluate documentation synchronization, changelog completeness, version classification, protected paths, and release accuracy without hard-coded fallback behavior.

## Downstream Impact Assessment

Phase 05 changes machine-readable policy manifests that downstream validators, adapters, documentation reviewers, release reviewers, and contract authors may consume. Affected consumers include:

- local validator checks that read policy registries
- optional workflow adapters that consume portable policy manifests
- release reviewers evaluating version and changelog consistency
- documentation managers reviewing wiki synchronization obligations
- downstream repositories that mirror or consume `core/policies/*.json`
- compatibility consumers of root `policies/*.json` mirrors

Migration guidance is required in the changelog because policy manifests will encode stricter path, docs, changelog, and release requirements.

## Scope

### In Scope

- `contracts/FAE-GOV-2026-05-10-008-policy-paths-docs-release-accuracy.md`
- `core/policies/repo-boundaries.json`
- `policies/repo-boundaries.json`
- `core/policies/docs-sync-rules.json`
- `policies/docs-sync-rules.json`
- `core/policies/changelog-rules.json`
- `policies/changelog-rules.json`
- `core/policies/versioning-rules.json`
- `policies/versioning-rules.json`
- `core/validator/forsetti_validate.ps1`
- `core/validator/contract_rules.ps1`
- `core/schemas/validator-result.schema.json`
- `core/README.md`
- `core/validator/README.md`
- `README.md`
- `DOCUMENTATION_POLICY.md`
- `RELEASE_POLICY.md`
- `CHANGE_CONTROL_POLICY.md`
- `COMPLIANCE_POLICY.md`
- `wiki/Documentation.md`
- `wiki/Releases.md`
- `wiki/Workflow.md`
- `wiki/Compliance.md`
- `wiki/Changelog.md`
- `wiki/Home.md`
- `wiki/Overview.md`
- `changelog/CHANGELOG.md`
- `.forsetti/remediation-v3/phase-05-report.md`
- `.forsetti/remediation-v3/phase-05-changed-files.txt`
- `.forsetti/remediation-v3/phase-05-validator-result.json`
- `.forsetti/remediation-v3/phase-05-contract-result.json`

### Out of Scope

- Constitutional amendments
- GitHub Actions adapter conversion
- Platform overlay generation
- Secret handling changes
- Historical changelog rewriting outside an explicit new Unreleased entry
- Product dependency on MCP servers, remote providers, hosted workflows, or advisory subagents
- Docker, WSL, and Playwright MCP setup

## Required Outputs

- `core/policies/repo-boundaries.json`
- `core/policies/docs-sync-rules.json`
- `core/policies/changelog-rules.json`
- `core/policies/versioning-rules.json`
- `.forsetti/remediation-v3/phase-05-report.md`
- `.forsetti/remediation-v3/phase-05-changed-files.txt`
- `.forsetti/remediation-v3/phase-05-validator-result.json`
- `.forsetti/remediation-v3/phase-05-contract-result.json`

## Documentation Impact

**README update required:** yes
**Wiki update required:** yes
**Changelog entry required:** yes
**Glossary update required:** no
**Rationale:** The policy manifests, local validator result model, README local validation guidance, and governance-derived wiki surfaces require synchronization. `DOCUMENTATION_POLICY.md` requires README, wiki, and changelog updates for breaking changes.

## Validation Requirements

- Parse all changed JSON files with local JSON tooling.
- Confirm root policy mirrors remain byte-identical to their `core/policies/` counterparts.
- Run the repository validator in strict mode.
- Run contract enforcement against this task contract and the changed-file set.
- Confirm no stale documented repository paths remain in changed policy manifests.
- Confirm documentation sync, changelog, and version policy data contains enforceable rule identifiers, rejection conditions, and evidence requirements.
- Confirm changelog migration guidance and affected consumers are present.
- Confirm no product dependency on MCP servers, remote providers, hosted workflows, or advisory subagents was introduced.

## Evidence Requirements

The Phase 05 report must include:

- Phase result
- Files changed
- Commands run
- MCP/tooling used
- Local-first and provider fallback decisions
- Advisory reviewer findings and disposition
- Validation results
- Unresolved issues
- Acceptance gate status

## Constraints

- Stay within this contract scope unless amended first.
- Do not add source, contributor, generated-by, co-author, or automation attribution.
- Do not modify protected governance assets outside this contract scope.
- Do not make product behavior depend on MCP servers, remote providers, hosted workflows, or advisory subagents.
- Do not treat Docker, WSL, or Playwright MCP as blockers for this phase.

## Escalation Triggers

- A required output cannot be produced.
- Policy mirror parity cannot be preserved.
- Local validation fails and cannot be remediated within contract scope.
- Provider identity cannot be verified.
- Additional protected assets must be modified outside this contract.

## Completion Summary Requirements

- Files changed
- Evidence of validation
- Known issues
- Documentation status
- Release impact
- Scope compliance

## Definition of Done

- [ ] Required outputs exist.
- [ ] JSON outputs parse.
- [ ] Policy mirrors are byte-identical.
- [ ] Stale paths are corrected or explicitly documented as retained by policy.
- [ ] Documentation, changelog, and version policy data is enforceable before merge.
- [ ] Retroactive governance mutation is prohibited by policy data.
- [ ] Repository validator strict mode passes or unresolved failures are documented with remediation.
- [ ] Contract enforcement validates authorized changed files.
- [ ] Documentation updates are complete.
- [ ] Changelog updates are complete.
- [ ] Breaking-change migration guidance is documented.
- [ ] Advisory reviewer findings are reconciled.
- [ ] Phase report is complete.
- [ ] Branch is pushed and pull request is created for repository-owner review.
