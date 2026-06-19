# Task Contract: Phase 07 Accountability and Non-Attribution

## Contract Identity

**Task ID:** FAE-GOV-2026-05-11-012
**Phase:** 07
**Branch:** fix/v3-accountability-no-attribution
**Created:** 2026-05-11
**Repository:** Forsetti Agentic Edition

## Role Assignment

**Contract Authoring Role:** Architect
**Acting Role:** Builder
**Reviewer Role:** Validator
**Release Review Role:** Release Manager
**Documentation Review Role:** Documentation Manager

## Required Advisory Reviewers

- architect-reviewer
- security-auditor
- security-reviewer
- prompt-engineer
- documenter
- code-reviewer

## Change Classification

**Change Class:** breaking-change
**Approval Class:** governance-class
**Release Impact:** major

## Governance Steward Authorization

**Required:** yes
**Authority:** Flynn33, repository owner and Governance Steward
**Evidence:** Flynn33 directed Phase 07 to proceed as a no-attribution accountability policy on 2026-05-11. The direction requires accountability evidence without attribution credit to any tool, model, vendor, automation, or agent.

## Objective

Establish a no-attribution accountability policy for assisted work. The policy must preserve accountable human ownership, governed role traceability, contract or remediation phase reference, review evidence, validation evidence, and required approval evidence while prohibiting attribution credit in governed delivery surfaces.

## Business Reason

The existing FAE-C012 rule establishes the principle that assistance must not replace accountable human ownership, but it does not enumerate the prohibited attribution surfaces or the permitted accountability record fields. Phase 07 closes that gap without adding redundant policy surfaces beyond the dedicated support policy and machine-readable support manifest.

## Current Rule

`COMPLIANCE_POLICY.md` previously required accountable ownership and allowed contract and evidence records for automated assistance while prohibiting source, commit, footer, or contributor attribution to automation unless a higher-authority policy explicitly allowed it.

## Proposed Rule

Create `ACCOUNTABILITY_POLICY.md` as a compliance support policy under `COMPLIANCE_POLICY.md`, and create `core/policies/accountability-rules.json`, with `policies/accountability-rules.json` as a byte-identical compatibility mirror. Update FAE-C012 and derived documentation so governed accountability records must identify only the accountable human owner, acting governed role, contract ID or remediation phase ID, review evidence, validation evidence, and approval evidence required by path, role, or approval-class policy.

Attribution credit to tools, models, vendors, automation, or agents is prohibited in source files, generated code comments, commit messages, changelog entries, release notes, README notices, contributor lists, authorship metadata, and documentation prose.

## Downstream Impact Assessment

FAE-C012 keeps its request-changes decision but is reframed from ambiguous assistance-record language to non-attribution accountability. Downstream validators, reviewers, documentation consumers, and policy manifest consumers must distinguish accountability evidence from attribution credit and collect the required accountability evidence fields.

## Backward Compatibility

This is a breaking governance change for compliance consumers because it adds explicit accountability evidence obligations and rejection conditions. No validator interface, workflow behavior, or adapter behavior change is included in this contract.

## Scope

### In Scope

- `contracts/FAE-GOV-2026-05-11-012-accountability-no-attribution.md`
- `ACCOUNTABILITY_POLICY.md`
- `COMPLIANCE_POLICY.md`
- `DOCUMENTATION_POLICY.md`
- `README.md`
- `core/README.md`
- `core/policies/accountability-rules.json`
- `policies/accountability-rules.json`
- `core/policies/compliance-rules.json`
- `policies/compliance-rules.json`
- `core/policies/docs-sync-rules.json`
- `policies/docs-sync-rules.json`
- `wiki/Home.md`
- `wiki/Overview.md`
- `wiki/Compliance.md`
- `wiki/Documentation.md`
- `wiki/Glossary.md`
- `wiki/Changelog.md`
- `changelog/CHANGELOG.md`
- `.forsetti/remediation-v3/phase-07-changed-files.txt`
- `.forsetti/remediation-v3/phase-07-contract-result.json`
- `.forsetti/remediation-v3/phase-07-validator-result.json`
- `.forsetti/remediation-v3/phase-07-report.md`

### Out of Scope

- `.github/workflows/**`
- `adapters/github-actions/workflows/**`
- workflow check implementation changes
- validator implementation changes
- schema changes
- role authority expansion
- release publication
- unrelated documentation cleanup
- Docker, WSL, Playwright, MCP installation, or IDE setup

## Required Outputs

- `ACCOUNTABILITY_POLICY.md`
- `core/policies/accountability-rules.json`
- `policies/accountability-rules.json`
- `.forsetti/remediation-v3/phase-07-report.md`
- `.forsetti/remediation-v3/phase-07-changed-files.txt`
- `.forsetti/remediation-v3/phase-07-validator-result.json`
- `.forsetti/remediation-v3/phase-07-contract-result.json`

## Documentation Impact

**README update required:** yes
**Wiki update required:** yes
**Changelog entry required:** yes
**Glossary update required:** yes
**Rationale:** Phase 07 adds a root compliance support policy, a machine-readable policy manifest, FAE-C012 updates, documentation sync manifest entries, and new governance terms. README, wiki, glossary, and changelog surfaces must stay synchronized.

## Validation Requirements

- Parse all changed JSON files with local JSON tooling.
- Confirm root policy mirrors remain byte-identical to their `core/policies/` counterparts.
- Run the repository validator in strict mode.
- Run contract enforcement against this task contract and the changed-file set.
- Confirm `ACCOUNTABILITY_POLICY.md` and FAE-C012 prohibit attribution credit across the required surfaces.
- Confirm accountability evidence requires a human accountable owner, governed role, contract or phase reference, review evidence, validation evidence, and required approval evidence.
- Confirm no product dependency on MCP servers, remote providers, hosted workflows, IDEs, or advisory subagents was introduced.
- Confirm breaking-change migration guidance and affected consumers are present in the changelog.

## Evidence Requirements

The Phase 07 report must include:

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
- Do not add attribution credit to any tool, model, vendor, automation, or agent.
- Do not modify workflow wrappers, adapter workflow scripts, validator implementation, schemas, or role authority rules in this phase.
- Do not create redundant user-facing policy surfaces when existing policy files already cover the requirement.
- Do not make product behavior depend on MCP servers, remote providers, hosted workflows, IDEs, or advisory subagents.
- Do not classify the change as governance-only because the policy adds required accountability evidence obligations for consumers.

## Risks

- Existing workflow guard implementation files contain enforcement-only restricted attribution patterns. Those files are out of scope for this policy contract and are not attribution credit.
- Broad text searches must distinguish prohibited attribution credit from policy and guard text that prohibits or detects it.

## Escalation Triggers

- Required outputs cannot be produced.
- Policy mirror parity cannot be preserved.
- Local validation fails and cannot be remediated within contract scope.
- Additional protected workflow, adapter script, validator, schema, or role authority changes are needed.
- Review identifies wording that credits, thanks, cites, lists, or attributes work to any tool, model, vendor, automation, or agent.

## Completion Summary Requirements

- Files changed
- Evidence of validation
- Known issues or limitations
- Documentation status
- Release impact
- Scope compliance

## Definition of Done

- [ ] Required outputs exist.
- [ ] JSON outputs parse.
- [ ] Policy mirrors are byte-identical.
- [ ] FAE-C012 is updated consistently in Markdown and JSON policy registries.
- [ ] Accountability policy prohibits attribution credit across required surfaces.
- [ ] Accountability evidence requires a human accountable owner and review trail.
- [ ] README, wiki, glossary, and changelog updates are complete.
- [ ] Breaking-change migration guidance and affected consumers are documented.
- [ ] Repository validator strict mode passes or unresolved failures are documented with remediation.
- [ ] Contract enforcement validates authorized changed files.
- [ ] Advisory reviewer findings are reconciled.
- [ ] Phase report is complete.
- [ ] Branch is pushed and pull request is created for repository-owner review.
