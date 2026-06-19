# Task Contract: Phase 08 Platform Overlays

## Contract Identity

**Task ID:** FAE-TASK-2026-05-11-013
**Phase:** 08
**Branch:** fix/v3-platform-overlays
**Created:** 2026-05-11
**Repository:** Forsetti Agentic Edition

## Role Assignment

**Contract Authoring Role:** Architect
**Acting Role:** Builder
**Reviewer Role:** Validator
**Release Review Role:** Release Manager
**Documentation Review Role:** Documentation Manager

## Required Advisory Reviewers

- architect
- architect-reviewer
- backend-developer
- security-auditor
- documenter
- code-reviewer

## Change Classification

**Change Class:** feature
**Approval Class:** sensitive
**Release Impact:** minor

## Governance Steward Authorization

**Required:** no
**Authority:** N/A
**Evidence:** Phase 08 expands additive platform overlay documentation and evidence. It does not modify constitutional, compliance, policy, validator, schema, workflow, or role authority files.

## Objective

Expand the generic, Apple, and Windows platform overlays from Phase 01 scaffolds into usable overlay guidance. The Apple overlay is the Apple-platform alignment profile for Apple-platform work. The Windows overlay aligns with the same platform alignment principles while preserving Windows-native validation and implementation paths. The generic overlay remains the fallback profile for host-neutral work.

## Business Reason

Phase 01 established overlay directories as scaffolds. Phase 08 must make those overlays useful without turning any platform, IDE, MCP server, hosted provider, or local tool into a portable core dependency.

## Downstream Impact Assessment

This is an additive, backward-compatible feature. Downstream consumers may opt into more detailed platform overlay guidance, but existing core policy, task contract, validator, adapter, and schema behavior is unchanged.

## Scope

### In Scope

- `contracts/FAE-TASK-2026-05-11-013-platform-overlays.md`
- `overlays/generic/README.md`
- `overlays/forsetti-apple/README.md`
- `overlays/forsetti-windows/README.md`
- `core/README.md`
- `README.md`
- `wiki/Home.md`
- `wiki/Overview.md`
- `wiki/Glossary.md`
- `wiki/Changelog.md`
- `changelog/CHANGELOG.md`
- `.forsetti/remediation-v3/phase-08-changed-files.txt`
- `.forsetti/remediation-v3/phase-08-validator-result.json`
- `.forsetti/remediation-v3/phase-08-contract-result.json`
- `.forsetti/remediation-v3/phase-08-report.md`

### Out of Scope

- `FORSETTI_CONSTITUTION.md`
- `AGENTS.md`
- `COMPLIANCE_POLICY.md`
- `ACCOUNTABILITY_POLICY.md`
- `CHANGE_CONTROL_POLICY.md`
- `RELEASE_POLICY.md`
- `DOCUMENTATION_POLICY.md`
- `core/policies/**`
- `policies/**`
- `core/validator/**`
- schemas
- workflow wrappers and adapter scripts
- role authority changes
- platform-specific implementation code
- product dependency on MCP servers, hosted providers, GitHub Actions, IDEs, Docker, WSL, or advisory subagents

## Required Outputs

- `overlays/generic/README.md`
- `overlays/forsetti-apple/README.md`
- `overlays/forsetti-windows/README.md`
- `.forsetti/remediation-v3/phase-08-report.md`
- `.forsetti/remediation-v3/phase-08-changed-files.txt`
- `.forsetti/remediation-v3/phase-08-validator-result.json`
- `.forsetti/remediation-v3/phase-08-contract-result.json`

## Documentation Impact

**README update required:** yes
**Wiki update required:** yes
**Changelog entry required:** yes
**Glossary update required:** yes
**Rationale:** Phase 08 expands overlay behavior that affects repository structure, platform guidance, and user understanding. README, wiki overview/home, glossary, and changelog must stay aligned.

## Validation Requirements

- Confirm all Phase 08 required overlay outputs exist.
- Parse generated validation evidence JSON with local JSON tooling.
- Run the repository validator in strict mode.
- Run contract enforcement against this task contract and the changed-file set.
- Confirm no core policy, validator, schema, workflow, or role authority files changed.
- Confirm no product dependency on MCP servers, hosted providers, GitHub Actions, IDEs, Docker, WSL, or advisory subagents was introduced.
- Confirm no prohibited attribution credit was added.

## Evidence Requirements

The Phase 08 report must include:

- phase result
- files changed
- commands run
- tooling used
- local-first and provider fallback decisions
- advisory reviewers used
- advisory reviewer findings and disposition
- validation results
- unresolved issues
- acceptance gate status

## Constraints

- Stay within this contract scope unless amended first.
- Keep overlays subordinate to root governance documents and canonical core policy registries.
- Do not redefine constitutional principles, compliance outcomes, task contract requirements, or role authority.
- Keep Apple and Windows overlay differences implementation-local; do not fork core governance meaning.
- Do not add attribution credit to any tool, model, vendor, automation, or agent.

## Risks

- Platform overlay language could accidentally become a new governance rule instead of derived guidance.
- Windows local-tool guidance could be misread as a portable core dependency.
- Apple platform alignment language could conflict with the repository constitution if not framed as subordinate overlay guidance.

## Escalation Triggers

- Required outputs cannot be produced.
- Additional protected governance or policy files must be modified.
- Overlay guidance would alter policy meaning, validator behavior, schemas, or role authority.
- Local validation fails and cannot be remediated within contract scope.
- Review identifies platform guidance that creates a mandatory product dependency outside the overlay.

## Definition of Done

- [ ] Generic overlay provides host-neutral operating guidance.
- [ ] Apple overlay provides platform alignment guidance without redefining root governance.
- [ ] Windows overlay aligns with the same platform alignment principles while preserving native Windows implementation guidance.
- [ ] README, wiki, glossary, and changelog are updated.
- [ ] Required evidence files exist.
- [ ] Repository validator strict mode passes.
- [ ] Contract validation passes.
- [ ] Advisory reviewer findings are reconciled.
- [ ] Branch is pushed and pull request is created for repository-owner review.

## Completion Summary Requirements

- Files changed
- Evidence of validation
- Known issues or limitations
- Documentation status
- Release impact
- Scope compliance
