# Task Contract: Phase 09 Final Validation, Regression, and Acceptance Audit

## Contract Identity

**Task ID:** FAE-TASK-2026-05-12-014
**Phase:** 09
**Branch:** test/v3-final-validation
**Created:** 2026-05-12
**Repository:** Forsetti Agentic Edition

## Role Assignment

**Contract Authoring Role:** Architect
**Acting Role:** Builder
**Reviewer Role:** Validator
**Release Review Role:** Release Manager
**Documentation Review Role:** Documentation Manager
**Accountable Human Owner:** Flynn33

## Role Separation Notes

- Architect authority is limited to creating and amending this task contract.
- Builder authority is limited to producing final audit evidence within contract scope.
- Validator authority is limited to scope, evidence, and compliance review.
- Release Manager authority is limited to final readiness and acceptance review; it does not replace Validator scope compliance review.
- Documentation Manager authority is limited to confirming changelog and wiki changelog synchronization for this evidence-only phase.
- Repository-owner PR review and merge remains the final approval path for this branch.

## Required Advisory Reviewers

- multi-agent-coordinator
- security-reviewer
- architect-reviewer
- code-reviewer
- test-writer
- performance-profiler
- documenter

## Change Classification

**Change Class:** release
**Approval Class:** release-critical
**Release Impact:** none

## Governance Steward Authorization

**Required:** no
**Authority:** N/A
**Evidence:** Phase 09 produces final validation, readiness, and acceptance audit evidence, plus release-traceability changelog synchronization. It does not modify constitutional, compliance, policy, validator, schema, workflow, role authority, adapter, overlay, source behavior, README, or unrelated documentation files.

## Objective

Run final local validation, inspect remediation evidence, perform required advisory reviews, and produce a final readiness and acceptance or fail decision for the v3 remediation package.

## Business Reason

The v3 remediation sequence needs a final audit that verifies required evidence exists, required outputs parse, validation gates pass, provider/tooling decisions were recorded, reviewer findings were reconciled, and no product dependency on optional tooling was introduced.

## Downstream Impact Assessment

This phase has no product or semantic version impact. It records final validation and readiness evidence for repository-owner review and does not change downstream governance behavior.

## Provider and Tooling Authorization

The repository owner has directed branch-and-pull-request review for each phase. GitHub remote push, pull request creation, pull request checks, and pull request review evidence are authorized for this phase. No other non-local third-party provider is authorized. Local tools and available MCP servers may be used as evidence collection resources only; they do not become product dependencies.

## Scope

### In Scope

- `contracts/FAE-TASK-2026-05-12-014-final-validation-audit.md`
- `.forsetti/remediation-v3/final-validation-changed-files.txt`
- `.forsetti/remediation-v3/final-validation-validator-result.json`
- `.forsetti/remediation-v3/final-validation-contract-result.json`
- `.forsetti/remediation-v3/final-validation-report.md`
- `.forsetti/remediation-v3/final-validation.json`
- `.forsetti/remediation-v3/final-acceptance-decision.md`
- `changelog/CHANGELOG.md`
- `wiki/Changelog.md`

### Out of Scope

- `FORSETTI_CONSTITUTION.md`
- `AGENTS.md`
- `COMPLIANCE_POLICY.md`
- `AI_ASSISTANCE_POLICY.md`
- `CHANGE_CONTROL_POLICY.md`
- `RELEASE_POLICY.md`
- `DOCUMENTATION_POLICY.md`
- `README.md`
- `core/**`
- `policies/**`
- `schemas/**`
- `scripts/**`
- `adapters/**`
- `overlays/**`
- `wiki/**` except `wiki/Changelog.md`
- `changelog/**` except `changelog/CHANGELOG.md`
- workflow files
- role authority changes
- product dependency on MCP servers, platform-supplied fallback tooling, GitHub Actions, hosted providers, IDEs, Docker, WSL, or advisory subagents

## Required Outputs

- `.forsetti/remediation-v3/final-validation-report.md`
- `.forsetti/remediation-v3/final-validation.json`
- `.forsetti/remediation-v3/final-acceptance-decision.md`
- `.forsetti/remediation-v3/final-validation-changed-files.txt`
- `.forsetti/remediation-v3/final-validation-validator-result.json`
- `.forsetti/remediation-v3/final-validation-contract-result.json`

## Documentation Impact

**README update required:** no
**Wiki update required:** yes
**Changelog entry required:** yes
**Glossary update required:** no
**Rationale:** Phase 09 produces validation, readiness, and acceptance evidence without changing user-facing behavior, governance meaning, product structure, or semantic version. Because the change class is release and it records final readiness evidence, the canonical changelog and derived wiki changelog are updated for release traceability.

## Validation Requirements

- Confirm all Phase 09 required outputs exist.
- Parse generated validation JSON with local JSON tooling.
- Run repository validator in strict mode.
- Run contract enforcement against this task contract and the changed-file set.
- Inspect all phase evidence files from Phase 00 through Phase 08.
- Confirm no protected governance, policy, validator, schema, workflow, documentation, changelog, adapter, overlay, or source behavior files changed.
- Confirm no non-local third-party provider was used without explicit approval.
- Confirm no product dependency on MCP servers, platform-supplied fallback tooling, GitHub Actions, hosted providers, IDEs, Docker, WSL, or advisory subagents was introduced.
- Confirm no prohibited attribution credit was added.
- Reconcile all required advisory reviewer findings.

## Evidence Requirements

The final validation report must include:

- phase result
- files changed
- commands run
- MCP servers/tooling used
- local-first and fallback decisions
- advisory reviewers used
- advisory reviewer findings and disposition
- validation results
- unresolved issues
- acceptance gate status

The final validation JSON must include:

- phase identifier
- branch
- task contract
- status
- changed files
- validation summaries
- tooling evidence
- advisory reviewer summaries
- acceptance gate results
- unresolved issues

## Constraints

- Stay within this contract scope unless amended first.
- Do not modify product, governance, policy, validator, schema, adapter, overlay, documentation, changelog, or workflow behavior while performing final validation.
- Do not add attribution credit to any tool, model, vendor, automation, or agent.
- Do not claim final acceptance unless validation and evidence support it.

## Risks

- Final validation may uncover a prior-phase issue that requires a separate remediation contract.
- Evidence may be incomplete or may not parse.
- Hosted checks may differ from local evidence if the pull request is not reviewed after push.

## Escalation Triggers

- Required outputs cannot be produced.
- Validation fails and cannot be remediated within this evidence-only contract scope.
- A protected or out-of-scope file must change.
- Provider identity cannot be verified.
- A product dependency on optional tooling is discovered.
- A prohibited attribution credit is discovered.

## Definition of Done

- [ ] Final validation report exists.
- [ ] Final validation JSON exists and parses.
- [ ] Final acceptance decision exists.
- [ ] Repository validator strict mode passes.
- [ ] Contract validation passes.
- [ ] Required remediation phase evidence is inspected.
- [ ] Required advisory reviewer findings are reconciled.
- [ ] No out-of-scope files are modified.
- [ ] Branch is pushed and pull request is created for repository-owner review.

## Completion Summary Requirements

- Files changed
- Evidence of validation
- Known issues or limitations
- Documentation status
- Release impact
- Scope compliance
