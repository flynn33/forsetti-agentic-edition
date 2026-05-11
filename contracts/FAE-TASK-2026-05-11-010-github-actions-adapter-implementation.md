# Task Contract: Phase 06A Governed Workflow and Adapter Implementation

## Contract Identity

**Task ID:** FAE-TASK-2026-05-11-010
**Phase:** 06A
**Branch:** fix/v3-github-adapter-06a
**Created:** 2026-05-11
**Repository:** Forsetti Agentic Edition

## Role Assignment

**Contract Authoring Role:** Architect
**Acting Role:** Governance Steward
**Reviewer Role:** Validator
**Release Review Role:** Release Manager
**Documentation Review Role:** Documentation Manager

## Required Advisory Reviewers

- devops-engineer
- backend-developer
- security-auditor
- git-workflow-manager
- code-reviewer

## Change Classification

**Change Class:** refactor
**Approval Class:** sensitive
**Release Impact:** patch

## Governance Steward Authorization

**Required:** yes
**Authority:** Flynn33, repository owner and Governance Steward
**Evidence:** Flynn33 directed Phase 06 to split into role-scoped child contracts on 2026-05-11. Phase 06A requires `.github/workflows/*.yml` and `adapters/github-actions/workflows/**` changes, and the repository boundary policy limits those path families to Architect or Governance Steward authority.

## Objective

Move GitHub-specific hosted workflow implementation into protected adapter scripts under `adapters/github-actions/workflows/` and make repository workflow files thin wrappers that preserve GitHub check names while keeping GitHub Actions optional.

## Business Reason

Forsetti Agentic Edition must keep canonical compliance behavior in repository-local policy and validation surfaces, not in hosted workflow YAML. Phase 06A implements the workflow and adapter portion only so path ownership rules remain intact.

## Composite Phase Relationship

Phase 06 is now a composite phase:

- Phase 06A covers governed workflow and adapter implementation under Governance Steward authority.
- Phase 06B covers README, wiki, changelog, release notes, and documentation synchronization under the role required by the path manifest.

Phase 06 is not complete until both Phase 06A and Phase 06B pass their contracts.

## Downstream Impact Assessment

Phase 06A affects GitHub-hosted workflow behavior and adapter execution. Existing workflow names and required PR check names should remain stable where feasible. Downstream consumers that inspect `.github/workflows/*.yml` directly should treat those files as wrappers and inspect `adapters/github-actions/workflows/` for host-specific implementation details after Phase 06B documents that behavior.

## Scope

### In Scope

- `contracts/FAE-TASK-2026-05-11-010-github-actions-adapter-implementation.md`
- `adapters/github-actions/workflows/**`
- `.github/workflows/*.yml`
- `.forsetti/remediation-v3/phase-06a-report.md`
- `.forsetti/remediation-v3/phase-06a-changed-files.txt`
- `.forsetti/remediation-v3/phase-06a-validator-result.json`
- `.forsetti/remediation-v3/phase-06a-contract-result.json`

### Out of Scope

- `README.md`
- `wiki/**`
- `changelog/**`
- release notes
- user-facing documentation outside existing Governance Steward path ownership
- constitutional amendments
- policy manifest schema changes
- core validator behavioral changes unless directly required for governed workflow enforcement
- contract template or schema changes
- platform overlay generation
- AI assistance disclosure policy changes
- Docker, WSL, and Playwright setup
- product dependency on MCP servers, hosted workflows, provider services, or advisory reviewers

## Required Outputs

- `adapters/github-actions/workflows/`
- `.github/workflows/`
- `.forsetti/remediation-v3/phase-06a-report.md`
- `.forsetti/remediation-v3/phase-06a-changed-files.txt`
- `.forsetti/remediation-v3/phase-06a-validator-result.json`
- `.forsetti/remediation-v3/phase-06a-contract-result.json`

## Documentation Impact

**README update required:** no
**Wiki update required:** no
**Changelog entry required:** no
**Glossary update required:** no
**Rationale:** Documentation and changelog synchronization are explicitly deferred to dependent Phase 06B so this implementation contract remains within Governance Steward-owned workflow and adapter path scope.

## Validation Requirements

- Parse changed JSON outputs with local tooling.
- Parse changed workflow YAML with available local tooling.
- Parse adapter PowerShell scripts with the local PowerShell parser.
- Run the repository validator in strict mode.
- Run contract enforcement against this Phase 06A task contract and changed-file set.
- Confirm workflows are wrappers around adapter-owned implementation scripts.
- Confirm no `tj-actions/changed-files` dependency remains in workflow wrappers.
- Confirm no product dependency on GitHub Actions, MCP servers, remote providers, Docker, WSL, browser automation, or advisory reviewers was introduced.
- Confirm no source, contributor, generated-by, co-author, or automation attribution was added.

## Evidence Requirements

The Phase 06A report must include:

- phase result
- files changed
- commands run
- MCP/tooling used
- local-first and provider fallback decisions
- advisory reviewer findings and disposition
- validation results
- unresolved issues
- acceptance gate status
- Phase 06B dependency statement

## Constraints

- Stay within this contract scope unless amended first.
- Preserve the no-attribution rule.
- Preserve existing required PR check names where feasible.
- Keep hosted workflow behavior optional and adapter-owned.
- Do not modify documentation or changelog files in Phase 06A.
- Do not modify core validator behavior in this phase unless directly required for governed workflow enforcement.
- Do not introduce new third-party hosted dependencies without explicit approval.
- Do not weaken path ownership rules or merge role authority.

## Risks

- GitHub-hosted checks may differ from local validation if workflow wrappers pass incomplete context to adapter scripts.
- Workflow YAML can pass local syntax checks while still requiring hosted validation after PR creation.
- Phase 06B must follow Phase 06A to document behavior and add changelog evidence before final Phase 06 acceptance.

## Escalation Triggers

- Scope must expand beyond workflow wrappers, adapter scripts, or evidence files.
- Workflow conversion requires policy manifest or core validator changes.
- Documentation, wiki, changelog, or release-note changes are needed before Phase 06A can pass.
- A hosted workflow check cannot be represented as an adapter wrapper.
- Local validation fails and cannot be remediated within this contract scope.

## Definition of Done

- [ ] Required Phase 06A outputs exist.
- [ ] Workflow wrappers delegate substantive hosted logic to adapter-owned scripts.
- [ ] Changed-file discovery is adapter-owned and does not depend on `tj-actions/changed-files`.
- [ ] Repository validation passes.
- [ ] Contract enforcement validates authorized changed files.
- [ ] Advisory reviewer findings are reconciled.
- [ ] Phase 06A report is complete and states Phase 06B remains required.
- [ ] Branch is pushed and pull request is created for repository-owner review.

## Completion Summary Requirements

- Files changed
- Evidence of validation
- Known issues or limitations
- Documentation status
- Release impact
- Scope compliance
