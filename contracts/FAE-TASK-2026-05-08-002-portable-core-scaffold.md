# Task Contract: Portable Core, Adapter, and Overlay Scaffold

## Task ID

**Value:** FAE-TASK-2026-05-08-002

## Title

**Value:** Portable core, adapter, and overlay scaffold

## Date

**Value:** 2026-05-08

## Initiating Request

**Value:** Remediation package v3 Phase 01, "Portable Core, Adapter, and Overlay Scaffold", requested by the repository owner.

## Acting Role

**Value:** builder

## Reviewer Role

**Value:** architect and validator

## Change Class

**Value:** feature

## Approval Class

**Value:** sensitive

## Objective

**Value:** Add the first portable Forsetti Agentic Edition scaffold by creating `core/`, `adapters/`, and `overlays/` documentation surfaces that separate host-neutral governance doctrine from optional host adapters and platform overlays.

`core/FORSETTI_AGENTIC_CONSTITUTION.md` is an additive, subordinate scaffold artifact for portable-core extraction. It does not amend, replace, supersede, or reinterpret root `FORSETTI_CONSTITUTION.md`.

## Business Reason

**Value:** The repository is currently organized as a GitHub-workflow-centered governance package. Phase 01 establishes the directory and documentation boundaries required for later phases to move validation, policy registry, adapter behavior, and platform-specific guidance into portable layers without making any external tool, hosted service, or automation provider a product dependency.

## In Scope

- `contracts/FAE-TASK-2026-05-08-002-portable-core-scaffold.md`
- `core/AGENTS.md`
- `core/README.md`
- `core/FORSETTI_AGENTIC_CONSTITUTION.md`
- `adapters/github-actions/README.md`
- `overlays/generic/README.md`
- `overlays/forsetti-apple/README.md`
- `overlays/forsetti-windows/README.md`
- `README.md`
- `wiki/Overview.md`
- `wiki/Home.md`
- `wiki/Glossary.md`
- `wiki/Changelog.md`
- `wiki/_Footer.md`
- `wiki/Agent-Roles.md`
- `wiki/Compliance.md`
- `wiki/Constitution.md`
- `wiki/Releases.md`
- `wiki/Workflow.md`
- `changelog/CHANGELOG.md`
- `.forsetti/remediation-v3/phase-01-report.md`
- `.forsetti/remediation-v3/phase-01-report.json`

## Out of Scope

- Root protected governance documents: `FORSETTI_CONSTITUTION.md`, `COMPLIANCE_POLICY.md`, `CHANGE_CONTROL_POLICY.md`, `RELEASE_POLICY.md`, `DOCUMENTATION_POLICY.md`
- Root agent instructions: `AGENTS.md`, `agents/*.md`
- Machine-readable policy manifests: `policies/*.json`
- JSON schemas: `schemas/*.json`
- GitHub workflow files and issue or pull request templates under `.github/`
- Validator engine implementation, canonical policy registry implementation, contract enforcement implementation, and GitHub Actions wrapper conversion
- Any product dependency on MCP servers, provider-specific tooling, GitHub Actions, sub-agents, Docker, WSL, Visual Studio, Visual Studio Code, or other local execution tooling

## Scope Notes

- `wiki/Overview.md` is authorized because `DOCUMENTATION_POLICY.md` maps `README.md` to `wiki/Overview.md` and the page is currently missing.
- `wiki/Home.md` is authorized because the existing wiki home page serves the repository overview role and must remain aligned with the README until the documented sync drift is resolved in a later policy/docs phase.
- Existing wiki pages listed in scope are authorized only to remove pre-existing footer source lines and preserve navigation. Broader content edits to those pages are out of scope unless otherwise listed above.
- Pre-existing drift in `policies/docs-sync-rules.json` is documented as an unresolved known issue. It is out of scope for Phase 01 because policy manifest repair is scheduled for a later phase.

## Required Outputs

- `core/AGENTS.md`
- `core/README.md`
- `core/FORSETTI_AGENTIC_CONSTITUTION.md`
- `adapters/github-actions/README.md`
- `overlays/generic/README.md`
- `overlays/forsetti-apple/README.md`
- `overlays/forsetti-windows/README.md`
- `.forsetti/remediation-v3/phase-01-report.md`
- `.forsetti/remediation-v3/phase-01-report.json`
- README, wiki, glossary, and changelog updates required by documentation policy

## Documentation Impact

- [x] README update required
- [x] Wiki update required
- [x] Glossary update required
- [ ] No documentation impact

## Release Impact

**Value:** minor

## Validation Requirements

- Confirm all Phase 01 required output files exist.
- Run Windows PowerShell repository validation with `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\validate-repo.ps1`.
- Run PowerShell 7 repository validation with `pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\validate-repo.ps1`.
- Parse `.forsetti/remediation-v3/phase-01-report.json` with `py -m json.tool` and `ConvertFrom-Json`.
- Run local file search and index checks with `rg --files` and targeted content scans.
- Run a targeted scan proving changed files contain no prohibited source or contributor lines.
- Identify tracked and untracked worktree state with `git diff --name-only HEAD`, `git ls-files --others --exclude-standard`, and `git status --short --untracked-files=all`; document pre-existing untracked artifacts that are excluded from Phase 01; after intentional staging, verify the staged Phase 01 payload with `git diff --cached --name-only`.
- Verify wiki pages with limited scope receive no broader content edits than authorized README/changelog/glossary sync, overview creation, navigation preservation, and footer source-line removal.
- Record local tooling, MCP availability, fallback decisions, sub-agent findings, validation results, known issues, and acceptance gate status in the Phase 01 report.
- Obtain architect-reviewer and code-reviewer findings and reconcile any actionable findings before completion.
- Obtain Documentation Manager confirmation for README, wiki, glossary, and changelog documentation status.
- Obtain Release Manager confirmation of `minor` version impact.

## Risks and Constraints

- The new scaffold must remain additive. If it changes existing root governance authority or forces existing consumers to adapt, the task must be reclassified.
- `core/FORSETTI_AGENTIC_CONSTITUTION.md` must describe portable core doctrine without superseding, amending, replacing, or reinterpreting `FORSETTI_CONSTITUTION.md`.
- GitHub Actions must be documented as an optional adapter, not a core dependency.
- MCP servers, local IDEs, sub-agents, and local tools may be used for remediation evidence, but must not become product dependencies.
- Existing documentation sync drift in `policies/docs-sync-rules.json` is known and out of scope for this phase.

## Escalation Triggers

- Any required output cannot be produced.
- Validation fails and cannot be remediated within authorized scope.
- Work requires modifying a protected governance asset.
- The scaffold would introduce a runtime, hosted-service, MCP, provider-specific tooling, GitHub Actions, IDE, Docker, WSL, or sub-agent dependency.
- The change becomes breaking for existing consumers.
- Documentation sync cannot be established or truthfully reported from available evidence.

## Definition of Done

- [ ] All in-scope changes implemented
- [ ] Documentation updated as required
- [ ] Changelog entry added
- [ ] Validation requirements met with evidence
- [ ] Completion summary produced with evidence
- [ ] No unresolved blocking issues

## Completion Summary Requirements

The completion summary submitted by the Builder must include all of the following:

- Files changed (complete list)
- Evidence of validation (specific results, not assertions)
- Known issues or limitations, or explicit "none"
- Documentation status (updated / needs-sync / not required)
- Release impact confirmed
- Scope compliance confirmed against this contract
