# Task Contract: Local Validator CLI

## Task ID

**Value:** FAE-TASK-2026-05-08-006

## Title

**Value:** Local validator CLI

## Date

**Value:** 2026-05-08

## Initiating Request

**Value:** Repository owner accepted Phase 02 and directed execution of the next remediation phase.

## Acting Role

**Value:** builder

## Reviewer Role

**Value:** validator

## Required Advisory Reviewers

**Value:** api-designer, backend-developer, test-writer, build-error-resolver, performance-engineer, code-reviewer, documentation_manager, and governance_steward

## Change Class

**Value:** feature

## Approval Class

**Value:** governance-class

## Governance Steward Authorization

**Value:** Flynn33 accepted Phase 02 and approved proceeding to Phase 03 on branch `fix/v3-local-validator-cli` on 2026-05-08.

## Objective

**Value:** Implement a portable local validator CLI, starting with a PowerShell-native core validator that runs on this Windows host without requiring MCP servers, hosted providers, GitHub Actions, GitHub CLI, WSL, network access, or sub-agents.

## Business Reason

**Value:** Phase 03 establishes repository-local validation as the enforcement surface that later phases can extend for task contracts, policy paths, optional GitHub adapters, and final acceptance. Existing root scripts perform limited smoke checks and do not provide a reusable core validator result model.

## In Scope

- `contracts/FAE-TASK-2026-05-08-006-local-validator-cli.md`
- `core/README.md`
- `core/validator/forsetti_validate.ps1`
- `core/validator/README.md`
- `core/schemas/validator-result.schema.json`
- `scripts/validate-repo.ps1`
- `scripts/validate-repo.sh`
- `README.md`
- `wiki/Overview.md`
- `wiki/Home.md`
- `changelog/CHANGELOG.md`
- `wiki/Changelog.md`
- `.forsetti/remediation-v3/phase-03-report.md`
- `.forsetti/remediation-v3/phase-03-validator-result.json`

## Out of Scope

- GitHub workflow conversion or adapter wrapper changes
- Task contract enforcement beyond Phase 03 validator scaffolding
- Protected path policy expansion reserved for Phase 05
- accountability policy changes reserved for Phase 07
- Platform overlay implementation reserved for Phase 08
- Docker, WSL, hosted services, or non-local third-party providers
- Changes to constitutional or root policy rule meanings

## Required Outputs

- PowerShell-native core validator CLI at `core/validator/forsetti_validate.ps1`
- Core validator documentation at `core/validator/README.md`
- Machine-readable validator result schema at `core/schemas/validator-result.schema.json`
- Root PowerShell validation wrapper delegated to the core validator
- Root shell validation wrapper delegated to the core validator when a local PowerShell host is available
- Phase 03 evidence report
- Validator JSON evidence output
- Changelog entry and derived wiki changelog sync
- README and derived wiki updates for the new local validator capability

## Documentation Impact

- [x] README update required
- [x] Wiki update required
- [ ] Glossary update required
- [ ] No documentation impact

## Release Impact

**Value:** minor

## Validation Requirements

- Parse all changed JSON files with `py -m json.tool`.
- Parse all changed JSON files with PowerShell `ConvertFrom-Json`.
- Run `core/validator/forsetti_validate.ps1 -RepoRoot . -Mode all -Strict`.
- Run `core/validator/forsetti_validate.ps1 -RepoRoot . -Mode all -Strict -OutputJson .forsetti/remediation-v3/phase-03-validator-result.json`.
- Verify the validator JSON output parses and conforms to `core/schemas/validator-result.schema.json` where local tooling permits schema validation.
- Run `scripts/validate-repo.ps1`.
- Run `scripts/validate-repo.ps1` through PowerShell 7.
- Run `scripts/validate-repo.ps1` through the Visual Studio Developer Command environment.
- Run `scripts/validate-repo.sh` if a local Bash-compatible shell is available.
- Run local source-line scan for prohibited attribution-style source lines.
- Run `git diff --check`.
- Verify changed files are within this contract scope.
- Obtain and reconcile required subagent/reviewer findings.

## Risks and Constraints

- The validator must not introduce a product dependency on MCP, provider-specific tooling, GitHub Actions, GitHub CLI, WSL, network access, hosted APIs, sub-agents, or non-local third-party providers.
- The root shell wrapper may be unable to run on a host without Bash; this is not a blocker if PowerShell validation passes and Bash availability is truthfully reported.
- Phase 03 must not implement Phase 04 contract enforcement or Phase 06 GitHub adapter conversion.
- The validator should read repository files and canonical policy manifests rather than redefining compliance rule meanings.

## Escalation Triggers

- A required output cannot be produced within the authorized scope.
- Local validator execution cannot run on the Windows host.
- Validation fails and cannot be remediated within the contract scope.
- A reviewer identifies a blocking issue that requires policy changes outside Phase 03 scope.

## Definition of Done

- [x] Required Phase 03 output files exist.
- [x] Core validator runs locally in strict all mode.
- [x] Validator can emit machine-readable JSON.
- [x] Validator JSON output parses.
- [x] Root validation scripts delegate to the core validator.
- [x] Documentation and changelog updates are complete.
- [x] Local validation matrix passes or any unavailable host tool is documented with a non-blocking reason.
- [x] Required subagent/reviewer outcomes are recorded and reconciled.
- [x] No unresolved blocking issues remain.

## Completion Summary Requirements

- Files changed
- Evidence of validation
- Known issues
- Documentation status
- Release impact
- Scope compliance
