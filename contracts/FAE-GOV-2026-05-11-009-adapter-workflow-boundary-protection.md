# Task Contract: Adapter Workflow Boundary Protection

## Contract Identity

**Task ID:** FAE-GOV-2026-05-11-009
**Branch:** fix/v3-adapter-workflow-boundary-protection
**Created:** 2026-05-11
**Repository:** Forsetti Agentic Edition

## Role Assignment

**Contract Authoring Role:** Architect
**Acting Role:** Builder
**Reviewer Role:** Validator
**Release Review Role:** Release Manager
**Documentation Review Role:** Documentation Manager

## Required Advisory Reviewers

- security-auditor
- git-workflow-manager
- code-reviewer

## Change Classification

**Change Class:** governance
**Approval Class:** governance-class
**Release Impact:** governance-only

## Governance Steward Authorization

**Required:** yes
**Authority:** Flynn33, repository owner and Governance Steward
**Evidence:** On 2026-05-11, Flynn33 confirmed creating a governance-class boundary-protection PR before continuing Phase 06 GitHub Actions adapter conversion.

## Objective

Protect `adapters/github-actions/workflows/**` before hosted workflow logic is moved into that adapter directory.

## Business Reason

Phase 06 will move executable GitHub Actions enforcement logic from `.github/workflows/*.yml` into adapter-owned scripts. Those scripts become hosted enforcement surfaces and must receive protected-path, role-limited-path, and approval-class coverage before the conversion proceeds.

## Downstream Impact Assessment

Future adapter workflow script changes must be made under an authorized task contract with sensitive approval or higher. This prerestricted-provider does not convert hosted workflows and does not change current workflow execution behavior.

## Scope

### In Scope

- `contracts/FAE-GOV-2026-05-11-009-adapter-workflow-boundary-protection.md`
- `core/policies/repo-boundaries.json`
- `policies/repo-boundaries.json`
- `wiki/Workflow.md`
- `wiki/Compliance.md`
- `wiki/Changelog.md`
- `changelog/CHANGELOG.md`
- `.forsetti/remediation-v3/phase-06-boundary-protection-report.md`
- `.forsetti/remediation-v3/phase-06-boundary-protection-changed-files.txt`
- `.forsetti/remediation-v3/phase-06-boundary-protection-validator-result.json`
- `.forsetti/remediation-v3/phase-06-boundary-protection-contract-result.json`

### Out of Scope

- GitHub Actions adapter conversion
- `.github/workflows/*.yml`
- `adapters/github-actions/workflows/**`
- Core validator behavior changes
- Policy schema changes
- Constitutional amendments
- accountability policy changes
- Platform overlay generation
- Docker, WSL, and Playwright setup

## Required Outputs

- `core/policies/repo-boundaries.json`
- `policies/repo-boundaries.json`
- `.forsetti/remediation-v3/phase-06-boundary-protection-report.md`
- `.forsetti/remediation-v3/phase-06-boundary-protection-changed-files.txt`
- `.forsetti/remediation-v3/phase-06-boundary-protection-validator-result.json`
- `.forsetti/remediation-v3/phase-06-boundary-protection-contract-result.json`

## Documentation Impact

**README update required:** no
**Wiki update required:** yes
**Changelog entry required:** yes
**Glossary update required:** no
**Rationale:** The repository boundary manifest changes, requiring derived workflow and compliance wiki sync. The changelog update requires the derived changelog wiki page to stay synchronized.

## Validation Requirements

- Parse changed JSON files with local JSON tooling.
- Confirm root policy mirror remains byte-identical to `core/policies/repo-boundaries.json`.
- Run the repository validator in strict mode.
- Run contract enforcement against this task contract and the changed-file set.
- Confirm `adapters/github-actions/workflows/**` is included in protected paths, role-limited path mappings, and approval-required mappings.
- Confirm no workflow conversion or adapter script implementation is included in this prerestricted-provider.

## Evidence Requirements

The boundary protection report must include:

- phase result
- files changed
- commands run
- tooling used
- advisory reviewer finding that triggered this prerestricted-provider
- validation results
- unresolved issues
- acceptance gate status

## Constraints

- Stay within this contract scope unless amended first.
- Preserve the no-attribution rule.
- Do not convert GitHub Actions workflows in this prerestricted-provider.
- Do not create adapter workflow scripts in this prerestricted-provider.
- Keep root and core repository boundary manifests byte-identical.

## Risks

- If this protection is omitted, Phase 06 would move enforcement logic into an under-protected adapter path.
- Hosted PR checks for this branch will still be the current pre-Phase-06 workflows.

## Escalation Triggers

- Additional protected assets must be modified outside this contract.
- Local validation fails and cannot be remediated within this scope.
- Workflow conversion becomes necessary to complete this prerestricted-provider.

## Definition of Done

- [ ] Boundary manifest protects `adapters/github-actions/workflows/**`.
- [ ] Root policy mirror is byte-identical.
- [ ] Required wiki and changelog sync is complete.
- [ ] Strict repository validation passes.
- [ ] Contract validation passes.
- [ ] Phase report is complete.
- [ ] Branch is pushed and pull request is created for repository-owner review.

## Completion Summary Requirements

- Files changed
- Evidence of validation
- Known issues or limitations
- Documentation status
- Release impact
- Scope compliance
