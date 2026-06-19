# Bugfix Contract

## Task ID

**Value:** FAE-BUG-2026-05-08-001

## Title

**Value:** Fix Windows repository validator root resolution and workflow inventory drift

## Date

**Value:** 2026-05-08

## Initiating Request

**Value:** User directive to stop remediation sequencing and fix the PowerShell validator root bug using the installed Windows IDE/toolchain.

## Acting Role

**Value:** builder

## Reviewer Role

**Value:** validator

## Change Class

**Value:** bugfix

## Approval Class

**Value:** standard

## Bug Description

**Value:** `scripts/validate-repo.ps1` computes `$RepoRoot` as the parent of the parent of `$PSScriptRoot`. Because the script lives under `scripts/`, this resolves to the parent workspace instead of the Forsetti Agentic Edition repository root. After the root calculation is corrected, the script also checks two stale workflow filenames that no longer match the repository.

## Expected Behavior

**Value:** The Windows validator should resolve the Forsetti repository root reliably from the script location and validate the current repository file inventory.

## Actual Behavior

**Value:** The Windows validator scans the parent workspace, reports required repository files as missing, and attempts to parse unrelated JSON outside the repository. Once root resolution is corrected, it reports missing `.github/workflows/changelog-check.yml` and `.github/workflows/docs-sync-check.yml` even though the repository has `.github/workflows/changelog-validation.yml` and `.github/workflows/docs-sync-agent.yml`.

## Root Cause

**Value:** The root calculation goes up two directory levels from `scripts/` instead of one, and the required workflow list retained two obsolete filenames.

## In Scope

- `contracts/FAE-BUG-2026-05-08-001-validator-root.md`
- `scripts/validate-repo.ps1`
- `changelog/CHANGELOG.md`
- `.forsetti/remediation-v3/validator-root-repair-report.md`
- `.forsetti/remediation-v3/validator-root-repair.json`

## Out of Scope

- Bash validator behavior.
- Docker installation or Docker-dependent workflows.
- WSL installation.
- Policy registry normalization.
- GitHub workflow conversion.
- Existing Phase 00, Phase 00A, and Phase 00B evidence files not named in this contract.
- Historical `.forsetti/remediation-v2/` evidence.
- Any unrelated validator refactor.

## Fix Description

**Value:** Replace the incorrect two-level root calculation with a script-root-based repository root resolver that points to the parent of `scripts/` and fails fast if the Forsetti root marker is not present. Align the required workflow filenames with the current repository workflow files.

## Verification Method

- Run the validator from repository root with Windows PowerShell.
- Run the validator from repository root with PowerShell 7.
- Run the validator from the Visual Studio Developer Command environment.
- Run the validator by absolute path from the parent workspace.
- Verify JSON evidence with Visual Studio Python through the `py` launcher and the bundled Python runtime.
- Confirm VS Code and Visual Studio tool availability with CLI evidence.

## Documentation Impact

- [ ] README update required
- [ ] Wiki update required
- [x] No documentation impact

## Release Impact

**Value:** patch

## Definition of Done

- [x] Bug is corrected
- [x] Fix verified using stated verification method
- [x] No drive-by edits or unrelated changes included
- [x] Documentation updated if required
- [x] Changelog entry added
- [x] Completion summary produced with evidence

## Prohibited Actions

- Fixing unrelated issues in the same files.
- Refactoring code or content beyond what is needed for the fix.
- Expanding scope to adjacent remediation phases.
- Claiming completion without running Windows-native validation.
- Modifying files not listed in the In Scope section.
- Bundling cleanup, formatting, or style changes with the fix.
