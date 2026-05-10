# Task Contract: Task Contract, Scope, Approval, and Evidence Enforcement

## Contract Identity

**Task ID:** FAE-GOV-2026-05-10-007
**Branch:** fix/v3-contract-enforcement
**Created:** 2026-05-10
**Repository:** Forsetti Agentic Edition

## Role Assignment

**Contract Authoring Role:** Architect
**Acting Role:** Builder
**Reviewer Role:** Validator
**Release Review Role:** Release Manager
**Documentation Review Role:** Documentation Manager

## Required Advisory Reviewers

- backend-developer
- api-designer
- test-writer
- security-auditor
- sentinel
- code-reviewer

## Change Classification

**Change Class:** breaking-change
**Approval Class:** governance-class
**Release Impact:** major

## Governance Steward Authorization

**Required:** yes
**Authority:** Flynn33, repository owner and Governance Steward
**Evidence:** In the active project thread on 2026-05-10, Flynn33 directed the next unfinished remediation phase to begin after establishing the branch-and-pull-request review workflow for phase work. This phase will be completed on branch `fix/v3-contract-enforcement`, pushed for pull request review, and merged only after repository-owner review.

## Objective

Make task contracts enforceable against changed files, protected paths, documentation and changelog impact, approvals, and validation evidence.

## Business Reason

The repository requires local, reproducible enforcement that meaningful work remains inside an authorized task contract, protected-path changes carry the required approval class, and completion claims include evidence.

## Downstream Impact Assessment

Phase 04 changes contract structure, validation modes, validator result categories, and local enforcement behavior. Affected consumers include:

- contract authors using `contracts/task-contract-template.md` or `core/contracts/task-contract-template.json`
- validators consuming `core/validator/forsetti_validate.ps1`
- scripts or adapters invoking repository validation modes
- documentation managers reviewing README and wiki synchronization
- release reviewers evaluating changelog and migration guidance
- downstream repositories or automation that parse `schemas/task-contract.schema.json`
- consumers that validate machine-readable output against `core/schemas/validator-result.schema.json`

Migration guidance is required in the changelog because the validator gains contract enforcement inputs and the task contract schema accepts the current date-stamped task ID format.

## Scope

### In Scope

- `contracts/FAE-GOV-2026-05-10-007-task-contract-scope-approval-evidence-enforcement.md`
- `core/schemas/task-contract.schema.json`
- `schemas/task-contract.schema.json`
- `core/contracts/task-contract-template.json`
- `contracts/task-contract-template.md`
- `core/validator/contract_rules.ps1`
- `core/validator/forsetti_validate.ps1`
- `core/schemas/validator-result.schema.json`
- `scripts/validate-repo.ps1`
- `scripts/validate-repo.sh`
- `core/README.md`
- `core/validator/README.md`
- `README.md`
- `wiki/Home.md`
- `wiki/Overview.md`
- `wiki/Workflow.md`
- `changelog/CHANGELOG.md`
- `wiki/Changelog.md`
- `.forsetti/remediation-v3/phase-04-report.md`
- `.forsetti/remediation-v3/phase-04-validator-result.json`
- `.forsetti/remediation-v3/phase-04-contract-result.json`

### Out of Scope

- Constitutional amendments
- Root policy document rewrites except documentation references already listed in scope
- `core/policies/*.json` policy registry changes
- GitHub Actions adapter conversion
- Platform overlay generation
- Secret handling changes
- Product dependency on MCP servers, remote providers, GitHub Actions, or advisory subagents
- Docker, WSL, and Playwright setup
- Historical branch cleanup

## Required Outputs

- `core/schemas/task-contract.schema.json`
- `core/contracts/task-contract-template.json`
- `core/validator/contract_rules.ps1`
- `.forsetti/remediation-v3/phase-04-report.md`
- `.forsetti/remediation-v3/phase-04-validator-result.json`
- `.forsetti/remediation-v3/phase-04-contract-result.json`

## Documentation Impact

**README update required:** yes
**Wiki update required:** yes
**Changelog entry required:** yes
**Glossary update required:** no

## Validation Requirements

- Parse all changed JSON files with local JSON tooling.
- Validate new task contract schema and JSON template locally.
- Run the repository validator in strict mode.
- Run contract enforcement against this task contract and the changed-file set.
- Exercise at least one negative changed-file scope case.
- Exercise at least one protected-path approval case.
- Confirm required outputs exist.
- Confirm documentation and changelog obligations are represented.
- Confirm no product dependency on MCP servers, remote providers, GitHub Actions, or advisory subagents was introduced.

## Evidence Requirements

The Phase 04 report must include:

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

- Stay within the scope listed above unless this contract is amended first.
- Do not add source, contributor, generated-by, co-author, or automation attribution.
- Do not modify protected governance assets outside this contract scope.
- Do not make product behavior depend on advisory subagents or MCP servers.
- Do not treat Docker, WSL, or Playwright as blockers for this phase.

## Escalation Triggers

- The required outputs cannot be produced.
- The validator cannot enforce changed-file scope without modifying files outside contract scope.
- Protected-path approval cannot be determined from local repository data.
- Local validation fails and cannot be remediated within contract scope.
- Additional protected assets must be modified.

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
- [ ] Contract enforcement validates authorized changed files.
- [ ] Contract enforcement blocks out-of-scope changed files.
- [ ] Protected-path approval checks run locally.
- [ ] Repository validator strict mode passes or unresolved failures are documented with remediation.
- [ ] Documentation updates are complete.
- [ ] Changelog updates are complete.
- [ ] Breaking-change migration guidance is documented.
- [ ] Advisory reviewer findings are reconciled.
- [ ] Phase report is complete.
- [ ] Branch is pushed and pull request is created for repository-owner review.
